class MoviesController < ApplicationController

  def movie_params
    params.require(:movie).permit(:title, :rating, :description, :release_date)
  end

  def show
    id = params[:id] # retrieve movie ID from URI route
    @movie = Movie.find(id) # look up movie by unique ID
    # will render app/views/movies/show.<extension> by default
  end

  def index
    @all_ratings = Movie.distinct.pluck(:rating)
    @ratings = (params[:ratings].present? ? params[:ratings] : @all_ratings)
    # debugger
    if params[:sort] == 'title'
      @movies = Movie.order('title ASC')
      @title_hilite = 'hilite'
      session[:sort] = params[:sort]
        if params[:ratings] && params[:sort] == 'title'
         @movies = Movie.where(rating: params[:ratings].keys).order('title ASC')
        end
    elsif params[:sort] == 'release_date'
      @movies = Movie.order('release_date ASC')
      @relese_date_hilite = 'hilite'
      session[:sort] = params[:sort]
        if params[:ratings] && params[:sort] == 'release_date'
         @movies = Movie.where(rating: params[:ratings].keys).order('release_date ASC')
        end
    elsif params[:ratings]
      @movies = Movie.where(rating: params[:ratings].keys)
      session[:ratings] = params[:ratings]
    else
      @movies = Movie.all
    end

    if params[:sort] != session[:sort] || params[:ratings] != session[:ratings]
      redirect_to movies_path sort: session[:sort], ratings: session[:ratings] and return
    end
  end

  def new
    # default: render 'new' template
  end

  def create
    @movie = Movie.create!(movie_params)
    flash[:notice] = "#{@movie.title} was successfully created."
    redirect_to movies_path
  end

  def edit
    @movie = Movie.find params[:id]
  end

  def update
    @movie = Movie.find params[:id]
    @movie.update_attributes!(movie_params)
    flash[:notice] = "#{@movie.title} was successfully updated."
    redirect_to movie_path(@movie)
  end

  def destroy
    @movie = Movie.find(params[:id])
    @movie.destroy
    flash[:notice] = "Movie '#{@movie.title}' deleted."
    redirect_to movies_path
  end

end
