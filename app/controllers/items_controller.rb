class ItemsController < ApplicationController
  before_action :set_item, only: [:show, :destroy]

  def index
    @items = Item.includes(:images).where(status_id: 1).order("id desc").limit(4)
    @items_ladies = Item.includes(:images).where(category_id: 1..198, status_id: 1).order("id desc").limit(4)
    @items_mens = Item.includes(:images).where(category_id: 199..343, status_id: 1).order("id desc").limit(4)
    @items_chanel = Item.includes(:images).where(brand_id: [2447,8386,11784,12827,13628], status_id: 1).order("id desc").limit(4)
  end

  def new
    @item = Item.new
    # itemクラスのインスタンスに関連づけられたImageクラスのインスタンスを作成
    @item.images.build
    @category = Category.where(ancestry: nil).order("id ASC")
  end

  def create
    @item = Item.new(item_params)
    @category = Category.all
    if @item.save
      redirect_to root_path
    else
      render 'new'
    end
  end

  def edit
  end

  def update
  end

  def show
    @images = @item.images
  end

  def destroy
    if @item.seller_id == current_user.id && @item.destroy
      redirect_to root_path
    else
      flash.now[:alert] = '削除に失敗しました'
      render :show
    end
  end

  
  def get_shipping_way
    @shipping_way = ShippingWay.find_all_by_group(params[:selected_fee])
  end
  
  def category_children
    @category_children = Category.find(params[:productcategory]).children
  end

  def category_grandchildren 
    @category_grandchildren = Category.find(params[:productcategory]).children
  end

  def get_size
    select_grandchild = Category.find("#{params[:grandchild_id]}") #孫カテゴリーを取得
    if related_size_parent = select_grandchild.sizes[0]#孫カテゴリーの紐づくサイズ(親)があれば取得
      @sizes = related_size_parent.children#紐づいたサイズ(親)の子供の配列を取得
    else
      select_child = Category.find("#{params[:grandchild_id]}").parent #孫カテゴリーの親を取得
      if related_size_parent = select_child.sizes[0] #孫カテゴリーの親と紐づくサイズ(親)があれば取得
        @sizes = related_size_parent.children #紐づいたサイズ(親)の子供の配列を取得
      end
    end
  end

  private
  def item_params
  # fields_forを利用して作成されたフォームから来る値は、○○s_attributes: [:××]という形でparamsに入る
  # fields_forから送られてくるこのキーを持った情報を頼りに、railsが子モデルの更新・削除を行う
    params.require(:item).permit(
      :name,
      :introduction,
      :category_id,
      :size_id,
      :brand_id,
      :condition_id,
      :shipping_fee_id,
      :shipping_way_id,
      :prefecture_id,
      :shipping_period_id,
      :price,
      images_attributes: [:image, :id, :_destroy]
      ).merge( seller_id: current_user.id)
  end

  def set_item
    @item = Item.find(params[:id])
  end

end


