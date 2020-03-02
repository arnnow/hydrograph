#!/usr/bin/env ruby
# Pull data from http://hubeau.eaufrance.fr/page/api-poisson
# And push it to influx

require 'yaml'
require 'logger'
require 'json'
require 'date'
require 'influxdb'
require_relative 'lib/platform/hubeau_fish'

## Load logger lib
begin
  require 'logger/colorz'
rescue LoadError
else
  Logger::Colors.send(:remove_const,:SCHEMA)
  Logger::Colors::SCHEMA = {
    STDOUT => %w[light_blue green brown red purple cyan],
    STDERR => %w[light_blue green yellow light_red light_purple light_cyan],
 }
end


#Load config File
config = YAML.load_file('config.yml')
INFLUXDBHOST = config['hubeau_poissons']['influx']['host']
INFLUXDBDATABASE = config['hubeau_poissons']['influx']['database']
POLLINGINTERVAL = config['pollinginterval']
INTERVAL = config['interval']

# Set Log Level
LOGLEVEL ||= Logger::DEBUG
$log = Logger.new(STDOUT)
$log.level = LOGLEVEL

$influxdb = InfluxDB::Client.new INFLUXDBDATABASE, host: INFLUXDBHOST

def updatehydro(payload,source)
	$influxdb.write_point(source,payload)
end


# Create Hubeau instance
HUBEAU_CONFIGURATION = config['hubeau_poissons']
@hubeau = Hubeau.new HUBEAU_CONFIGURATION

while true
	annees = (config['hubeau_poissons']['since'].to_i...Time.now.year.to_i + 1).step(1).to_a.join(',')
	departements = config['hubeau_poissons']['departement']
	poissons = config['hubeau_poissons']['poissons']
	departements.each do |departement|
		$log.info "Polling "+departement
		poissons.each do |poisson|
			lieux_list = @hubeau.getLieux(code_departement: departement,code_espece_poisson: poisson)
			lieux_list.each do |lieu|
				if lieu['localisation'] == nil
					next
				end
				poissons_list = @hubeau.getPoissons(code_station: lieu['code_station'], annee:annees)
				$log.info "Polling "+departement+" Site: " +  lieu['localisation'] + "("+lieu['code_station']+"): " + poissons_list.length.to_s + " Especes" 
				poissons_list.each do |poisson|
				    if poisson['date_operation'] == nil
				    	next
				    end
	        	            puts "Date Operation : "+poisson['date_operation'].to_s
				    epoch = Time.parse(poisson['date_operation']).to_i
				    payload = {
					    "values": {
						    "epoch":	 		epoch,
						    "effectif": 		poisson['effectif'],
						    "poids":			poisson['poids'],
						    "densite":			poisson['densite'],
						    "surface_peche":		poisson['surface_peche'],
					    },
					    "timestamp": epoch,
					    "tags": {
						    "poisson":			poisson['nom_poisson'],
						    "source": 			"hubeau_poissons",
						    "longitude":		poisson['x'],
						    "latitude":			poisson['y'],
						    "localisation": 		poisson['localisation'],
					    },
				    }
				    updatehydro(payload,departement)
				end
			end
		end
	end
	sleep(POLLINGINTERVAL)
end
