require 'auth/authenticate_system'
class ApplicationController < ActionController::Base
  PAGE_ALL_SIZE = 1000
 
  protected
  def error_500
    {:isSuccessful=>false,
      :message =>'internal failed problem.',
      :statusCode =>'500'
     }.to_json()
  end
  def select_defaultresource(resource)
    default_resource = resource.select{|r| r[:isDefault]==true}
    default_resource = resource.select{|r| r[:type]==1}.sort_by {|x| [x[:sortOrder],x[:id]]} if default_resource.nil?
    default_resource.first
  end
  def select_defaultaudioresource(resource)
    resource.select{|r| r[:type]==2}.sort{|x,y| y[:sortOrder].to_i<=>x[:sortOrder].to_i}.first
  end
end
