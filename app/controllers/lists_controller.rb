class ListsController < ApplicationController
  def index
    @lists = List.all
    @list = List.new
  end

  def show
    @list = List.find(params["id"])
    @bookmark = Bookmark.new
  end

  def new
    @list = List.new
  end

  def destroy
    @list = List.find(params["id"])
    @list.destroy
    redirect_to lists_path
  end

  def create
    @list = List.new(list_params)
    if @list.save
      respond_to do |format|
        format.turbo_stream do
          render turbo_stream: [
            turbo_stream.append("lists", partial: "lists/list", locals: { list: @list }),
            turbo_stream.remove("new_list_modal") # closes modal
          ]
        end
      format.html { redirect_to lists_path }
      end
    else
      respond_to do |format|
        format.turbo_stream do
          render turbo_stream: turbo_stream.replace(
            "new_list_modal",
            partial: "lists/form",
            locals: { list: @list }
          ), status: :unprocessable_entity
        end

        format.html do
          @lists = List.all
          render "home/index", status: :unprocessable_entity
        end
      end
    end

  end

  private

  def list_params
    params.require(:list).permit(:name, :photo)
  end
end
