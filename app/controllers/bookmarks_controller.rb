class BookmarksController < ApplicationController
  def new
    @list = List.find(params["list_id"])
    @bookmark = Bookmark.new
  end

  def destroy
    @bookmark = Bookmark.find(params["id"])
    @list = @bookmark.list
    @bookmark.destroy
    redirect_to list_path(@list)

  end

  def create
    @list = List.find(params["list_id"])
    @bookmark = Bookmark.new(bookmark_params)
    @bookmark.list = @list
    if @bookmark.save
      # redirect_to list_path(@list)
      respond_to do |format|
        format.turbo_stream do
          render turbo_stream: [
            turbo_stream.append(
            "bookmarks",
            partial: "bookmarks/bookmark",
            locals: { bookmark: @bookmark }
          ),
            turbo_stream.replace(
            "bookmark_form",
            partial: "bookmarks/form",
            locals: { list: @list, bookmark: Bookmark.new }
          )
        ]
        end
        format.html { redirect_to list_path(@list) }
      end
    else
      respond_to do |format|
        format.turbo_stream do
          render turbo_stream: turbo_stream.replace(
            "bookmark_form",
            partial: "bookmarks/form",
            locals: { list: @list, bookmark: @bookmark }
          ), status: :unprocessable_entity
        end

        format.html do
          render "lists/show", status: :unprocessable_entity
        end
      end
    end
  end

  private

  def bookmark_params
    params.require(:bookmark).permit(:comment, :movie_id)
  end
end
