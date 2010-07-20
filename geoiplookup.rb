require 'rubygems'
require 'sinatra'

configure do
	require 'geoip'
 	require 'json'

	require 'haml'
	set :haml, {:format => :html5 }

	GEOIP = GeoIP.new('GeoLiteCity.dat')
end

helpers do
	def lookup(host)
		
		results = perform_lookup(host)
		
		fields_and_values = { :hostname => results[0],
							  :ip => results[1],
							  :cc_alpha2 => results[2],
							  :cc_alpha3 => results[3],
							  :country_name => results[4],
							  :continent => results[5],
							  :state => results[6],
							  :city => results[7],
							  :zipcode => results[8],
							  :latitude => results[9],
							  :longitude => results[10]
							}
	
		fields_and_values[:dma_code] = results[11] if results[11]
		fields_and_values[:area_code] = results[12] if results[12]
	
		return fields_and_values
	end

	private
	
	def perform_lookup(host)
		begin
			results = GEOIP.city(host)
		rescue
			halt 404, "host #{host} not found"
		end
		
		halt 404, "No info found for #{host}" unless results		
	
		return results
	end
end


get '/:lookup.json' do
	content_type :json
	resolved = lookup(params[:lookup])
	
	resolved.to_json
end

get '/:lookup' do
	@resolved = lookup(params[:lookup])
	
	haml :lookup
end

get '/' do
	File.open('public/index.html').read
end
