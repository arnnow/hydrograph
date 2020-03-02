require 'rest-client'
require 'json'

class Hubeau

  def initialize(configuration)
    @url = configuration['base_url']
    @uri = configuration['base_uri']
    @lieux = '/etat_piscicole/lieux_peche'
    @code_espece_poisson = '/etat_piscicole/code_espece_poisson'
    @poissons = '/etat_piscicole/poissons'
  end

  def getLieux(bbox:"",code_commune:"",code_departement:"",code_espece_poisson:"",code_sous_secteur_hydrographique:"",
	      fields:"",format:"json",mois_debut:"",mois_fin:"",page:"",size:"20",srid:"")
	  options = {
		  bbox:bbox,
		  code_commune:code_commune,
		  code_departement:code_departement,
		  code_espece_poisson:code_espece_poisson,
		  code_sous_secteur_hydrographique:code_sous_secteur_hydrographique,
		  fields:fields,
		  format:format,
		  mois_debut:mois_debut,
		  mois_fin:mois_fin,
		  page:page,
		  size:size,
		  srid:srid,
	  }
    	  options.delete_if { |key, value| value.to_s.strip == '' }
    	  response = RestClient.get @url+@uri+@lieux, {params: options}
    	  result = JSON.parse(response.body)
    	  data = result['data']
    	  while response.code == 206 && result['next'] != nil
    	    response = RestClient.get result['next']
    	    result = JSON.parse(response.body)
    	    (data << result['data']).flatten!
    	  end
    	  return data


  end

  def getEspece(code:"",fields:"",page:"",size:"20")
	  options = {
		  code:code,
		  fields:fields,
		  page:page,
		  size:size,
	  }
       	  options.delete_if { |key, value| value.to_s.strip == '' }
       	  response = RestClient.get @url+@uri+@code_espece_poisson, {params: options}
       	  result = JSON.parse(response.body)
       	  data = result['data']
       	  while response.code == 206 && result['next'] != nil
       	    response = RestClient.get result['next']
       	    result = JSON.parse(response.body)
       	    (data << result['data']).flatten!
       	  end
       	  return data


  end

  def getPoissons(annee:"",code_espece_poisson:"",code_station:"",date_debut:"",date_fin:"",fields:"",format:"json",mois_debut:"",
		mois_fin:"",page:"",size:"20",srid:"")

       	  options = {
		  annee:annee,
		  code_espece_poisson:code_espece_poisson,
		  code_station:code_station,
		  date_debut:date_debut,
		  date_fin:date_fin,
		  fields:fields,
		  format:format,
		  mois_debut:mois_debut,
		  mois_fin:mois_fin,
		  page:page,
		  size:size,
		  srid:srid,
       	  }

       	  options.delete_if { |key, value| value.to_s.strip == '' }
       	  response = RestClient.get @url+@uri+@poissons, {params: options}
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
