class DriveController < ApplicationController

  def show
    @current_user = get_current_user
    respond_with_user_files
  end

  private def respond_with_user_files
    files = @current_user.root_folder.files
    user_serializer = UserSerializer.new(user: @current_user)
    response_body = UserSerializer.serialize_with_files_as_json(files)
    render json: response_body, status: 200
  end

  def create
    @current_user = get_current_user
    folder = @current_user.root_folder
    folder.files.attach(params[:file])
    render json: { message: "Success!" }, status: 200
  end

  def file_params
    params.permit(:file)
  end


end
