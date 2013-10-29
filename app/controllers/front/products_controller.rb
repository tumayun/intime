# encoding: utf-8
class Front::ProductsController < Front::BaseController 


  def show
    @product = Stage::Product.fetch(params[:id])
  end

  def index
  end

  def his_favorite_api
    options = {
      page: params[:page],
      pagesize: 10,
      sourcetype: params[:loveType],
      userid:     params[:userid]
    }
    result  = API::Product.his_favorite(request, options)
    results = result["data"].slice("pageindex", "pagesize", "totalcount", "totalpaged")
    results.merge! (gen_data(result["data"]["items"]))
    render :json =>results.to_json , callback: params[:callback]
  end

  def search_api
    options = {
      page: params[:page],
      pagesize: 10,
      term: params[:term]
    }
    result  = Stage::Product.search(options)
    results = result["data"].slice("pageindex", "pagesize", "totalcount", "totalpaged")
    results.merge! (gen_search_data(result["data"]["products"]))
    render :json =>results.to_json , callback: params[:callback]
  end

  def list
    @stores   = Stage::Store.list
    @brands   = gen_brands(Stage::Brand.group_brands)
    @tags     = Stage::Tag.list
    @hotwords = Stage::HotWord.list
  end

  def gen_brands(brands)
    result = {}
    ('A'..'Z').to_a.each do |character|
      brand_array = brands[:brands].select{|brand| brand[character] }
      if brand_array.present?
        result[character] = brand_array.first[character]
      end
    end
    result
  end

  def list_api
    options = {
      page: params[:page],
      pagesize: 10
    }
    options.merge!(covert_options_for_search(params[:type], params[:entity_id]))
    result  = Stage::Product.list(options)
    results = result["data"].slice("pageindex", "pagesize", "totalcount", "totalpaged")
    results.merge! (gen_data(result["data"]["products"]))
    render :json =>results.to_json , callback: params[:callback]
  end

  def my_favorite_api
    options = {
      page: params[:page],
      pagesize: 10,
      sourcetype: params[:loveType]
    }
    result  = API::Product.my_favorite(request, options)
    results = result["data"].slice("pageindex", "pagesize", "totalcount", "totalpaged")
    results.merge! (gen_data(result["data"]["items"]))
    render :json =>results.to_json , callback: params[:callback]
  end

  #当传userid时 是他的分享，没传是当前用户的分享
  def my_share_list_api
    options = {
      page: params[:page],
      pagesize: 10,
      userid: params[:userid]
    }

    result = API::Product.my_share_list(request, options)

    results = result["data"].slice("pageindex", "pagesize", "totalcount", "totalpaged")
    results.merge! (gen_data(result["data"]["items"]))
    render :json =>results.to_json , callback: params[:callback]
  end

  def favor
    API::Product.favor(request, productid: params[:id])

    respond_to { |format| format.js }
  end

  def unfavor
    API::Product.unfavor(request, productid: params[:id])

    respond_to { |format| format.js }
  end

  def download_coupon
    API::Product.download_coupon(request, productid: params[:id])

    respond_to { |format| format.js }
  end

  def comment
    @comment = API::Comment.create(request, params.slice(:content, :replyuser).merge(sourceid: params[:id], sourcetype: 1))

    respond_to { |format| format.js }
  end

  protected

  def covert_options_for_search(type, entity_id)
    options = {}
    if type == 'category'
      options[:tagid]    = entity_id
    elsif type == 'brand'
      options[:brandid]  = entity_id
    elsif type == 'store'
      options[:storied]  = entity_id
    elsif type =='sortby' 
      options[:sortby] = entity_id
    end
    options
  end

  def gen_search_data(datas)
    results = {}
    items = []
    datas && datas.each do |item|
      image_info = item["resources"].first
      items << {
        title:     item["name"],
        price:     item["price"],
        originalPrice:  item["unitprice"],
        likeCount: item["likecount"],
        url:       front_product_path(item["id"]||item["productid"]),
        imageUrl:  image_info.blank? ? "" : middle_pic_url(image_info)
      }
    end
    results[:datas] = items
    results
  end

  def gen_share(datas)
    results = {}
    items = []
    datas && datas.each do |item|
      image_info = item["resources"].first
      items << {
        title:     item["productname"],
        price:     item["price"],
        originalPrice:  item["originprice"],
        likeCount: item["likecount"],
        url:       front_product_path(item["id"]||item["productid"]),
        imageUrl:  image_info.blank? ? "" : middle_pic_url(image_info)
      }
    end
    results[:datas] = items
    results
  end

  def gen_data(datas)
    results = {}
    items = []
    datas && datas.each do |item|
      image_info = item["resources"].first if item["resources"].present?
      items << {
        title:     item["name"].blank? ? item["productname"] : item["name"],
        price:     item["price"],
        originalPrice:  item["price"],
        likeCount: item["likecount"],
        url:       front_product_path(item["id"]||item["productid"]),
        imageUrl:  image_info.blank? ? "" : middle_pic_url(image_info),
        flag: item["promotionFlag"]
      }
    end
    results[:datas] = items
    results
  end

end
