#!/usr/bin/env ruby
# Set a Crypto Trading program

require 'yaml'
require 'logger'
require 'json'
require 'date'
require 'influxdb'
require_relative 'lib/platform/hubeau'

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
INFLUXDBHOST = config['influxdb']['host']
INFLUXDBDATABASE = config['influxdb']['database']
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
HUBEAU_CONFIGURATION = config['hubeau']
@hubeau = Hubeau.new HUBEAU_CONFIGURATION

period = Time.new - INTERVAL
while true
	departements = config['hubeau']['departement'].join(',')
	sites_list = @hubeau.getSites(code_departement: departements)
	sites_list.each do |site|

		stations_list = @hubeau.getStations(code_site: site['code_site'])
		stations_list.each do |station|
		    observations_tr = @hubeau.getObservations_tr(code_entite: station['code_station'], date_debut_obs: period.strftime('%Y-%m-%dT%H:%M:%S.%L%z'), size: "100")
		    $log.info "Polling "+station['code_departement']+" Site: " +  site['libelle_site'] + " - Station: " + station['libelle_station'] + " ("+station['code_station']+"): " + observations_tr.length.to_s + " Observations" 
		    observations_tr.each do |observation|
			    epoch = Time.iso8601(observation['date_obs']).to_i
			    payload = {
				    "values": {
					    "epoch":	 		epoch,
					    "resultat_obs": 		observation['resultat_obs'],
				    },
				    "timestamp": epoch,
				    "tags": {
					    "source": 			"hubeau",
					    "longitude_station":	station['longitude_station'],
					    "latitude_station":		station['latitude_station'],
					    "libelle_station": 		station['libelle_station'],
					    "libelle_site":		site['libelle_site'],
					    "libelle_commune":		station['libelle_commune'],
					    "libelle_departement": 	station['libelle_departement'],
					    "code_departement":		station['code_departement'],
					    "libelle_cours_eau": 	station['libelle_cours_eau'] || station['libelle_cours_eau'] = "Null",
					    "code_region": 		station['code_region'],
					    "code_station": 		station['code_station'],
					    "grandeur_hydro": 		observation['grandeur_hydro'],
					    "libelle_region":		station['libelle_region'],
				    },
			    }
		
			    updatehydro(payload,station['libelle_region'])
		    end
		end
	end
	sleep(POLLINGINTERVAL)
end
