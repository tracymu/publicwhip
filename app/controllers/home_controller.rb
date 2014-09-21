require 'open-uri'

class HomeController < ApplicationController
  def index
    @divisions = Division.with_rebellions.order("date DESC", "clock_time DESC", "name", "number DESC").limit(5)
  end

  def about
  end

  def search
    if params[:query] =~ /^\d{4}$/
      @postcode = params[:query]

      # Temporary work around for https://github.com/openaustralia/openaustralia/issues/502
      json_response = open("http://www.openaustralia.org/api/getDivisions?output=js&key=CcV3KBBX2Em7GQeV3RA8qzgS&postcode=#{@postcode}").read
      json_response = "{\"error\":\"Unknown postcode\"}" if json_response == "{\"error\":\"Unknown postcode\"}{}"
      electorates = JSON.parse(json_response)

      if electorates.respond_to?("has_key?") && electorates.has_key?("error")
        @postcode_error = electorates["error"]
        return
      end

      if electorates.count == 1
        member = Member.find_by_constituency(electorates.first['name'])
        # FIXME: We should redirect but this is how the PHP app does it currently
        render nothing: true, status: :found, location: view_context.electorate_path2(member)
        return
      elsif electorates.count > 1
        @mps = []
        electorates.each do |e|
          member = Member.find_by_constituency(e['name'])
          @mps << member unless member.nil?
        end
      end
    elsif !params[:query].blank?
      @mps = Member.find_by_search_query params[:query]
      @divisions = Division.find_by_search_query params[:query]
    elsif params[:query].blank?
      redirect_to 'home#index'
      flash[:warning] = "Please enter a search term"
    end
  end
end
