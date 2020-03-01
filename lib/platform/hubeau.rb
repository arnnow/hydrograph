require 'rest-client'
require 'json'

class Hubeau

  def initialize(configuration)
    @url = configuration['base_url']
    @uri = configuration['base_uri']
    @stations = '/referentiel/stations'
    @observantion_tr = '/observations_tr'
    @site = '/referentiel/sites'
  end

  def getObservations_tr(bbox:"",code_entite:"",cursor:"",date_debut_obs:"",date_fin_obs:"",distance:"",fields:"",grandeur_hydro:"",
			latitude:"",longitude:"",size:"",sort:"",timestep:"")
	  options = {
		  bbox:bbox,
		  code_entite:code_entite,
		  cursor:cursor,
		  date_debut_obs:date_debut_obs,
		  date_fin_obs:date_fin_obs,
		  distance:distance,
		  fields:fields,
		  grandeur_hydro:grandeur_hydro,
		  latitude:latitude,
		  longitude:longitude,
		  size:size,
		  sort:sort,
		  timestep:timestep
	  }
    	  options.delete_if { |key, value| value.to_s.strip == '' }
    	  response = RestClient.get @url+@uri+@observantion_tr, {params: options}
    	  result = JSON.parse(response.body)
    	  data = result['data']
    	  while response.code == 206 && result['next'] != nil
    	    response = RestClient.get result['next']
    	    result = JSON.parse(response.body)
    	    (data << result['data']).flatten!
    	  end
    	  return data


  end

  def getSites(bbox:"",code_commune_site:"",code_cours_eau:"",code_departement:"",code_region:"",code_site:"",code_troncon_hydro_site:"",
	      code_zone_hydro_site:"",distance:"",fields:"",format:"json",latitude:"",libelle_cours_eau:"",libelle_site:"",
	      longitude:"",page:"",size:"100")
	  options = {
		  bbox:bbox,
		  code_commune_site:code_commune_site,
		  code_cours_eau:code_cours_eau,
		  code_departement:code_departement,
		  code_region:code_region,
		  code_site:code_site,
		  code_troncon_hydro_site:code_troncon_hydro_site,
		  code_zone_hydro_site:code_zone_hydro_site,
		  distance:distance,
		  fields:fields,
		  format:format,
		  latitude:latitude,
		  libelle_cours_eau:libelle_cours_eau,
		  libelle_site:libelle_site,
		  longitude:longitude,
		  page:page,
		  size:size
	  }
       	  options.delete_if { |key, value| value.to_s.strip == '' }
       	  response = RestClient.get @url+@uri+@site, {params: options}
       	  result = JSON.parse(response.body)
       	  data = result['data']
       	  while response.code == 206 && result['next'] != nil
       	    response = RestClient.get result['next']
       	    result = JSON.parse(response.body)
       	    (data << result['data']).flatten!
       	  end
       	  return data


  end

  def getStations(bbox:"",code_commune_station:"",code_cours_eau:"",code_departement:"",code_region:"",code_sandre_reseau_station:"",
		  code_site:"",code_station:"",date_fermeture_station:"",date_ouverture_station:"",distance:"",en_service:"",
		  fields:"",format:"json",latitude:"",libelle_cours_eau:"",libelle_site:"",libelle_station:"",longitude:"",
		  page:"",size:"20")

       	  options = {
       	          bbox:bbox,
       	          code_commune_station:code_commune_station,
       	          code_cours_eau:code_cours_eau,
       	          code_departement:code_departement,
       	          code_region:code_region,
       	          code_sandre_reseau_station:code_sandre_reseau_station,
       	          code_site:code_site,
       	          code_station:code_station,
       	          date_fermeture_station:date_fermeture_station,
       	          date_ouverture_station:date_ouverture_station,
       	          distance:distance,
       	          en_service:en_service,
       	          fields:fields,
       	          format:format,
       	          latitude:latitude,
       	          libelle_cours_eau:libelle_cours_eau,
       	          libelle_site:libelle_site,
       	          libelle_station:libelle_station,
       	          longitude:longitude,
       	          page:page,
       	          size:size
       	  }

       	  options.delete_if { |key, value| value.to_s.strip == '' }
       	  response = RestClient.get @url+@uri+@stations, {params: options}
       	  result = JSON.parse(response.body)
       	  data = result['data']
       	  while response.code == 206 && result['next'] != nil
       	    response = RestClient.get result['next']
       	    result = JSON.parse(response.body)
       	    (data << result['data']).flatten!
       	  end
       	  return data

  end

end
