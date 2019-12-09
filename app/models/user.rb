class User < ApplicationRecord
  include Error, StorageCalculator

  has_secure_password

  has_many :documents
  has_many :folders

  after_create :create_root_folder

  validates :name, :email, :password, {
    presence: true
  }

  validates :name, {
    format: {
      with: ValidationRegexps::NAME,
      message: "must be 2-50 chars (only letters, spaces, - and ')."
    }
  }

  validates :email, {
    uniqueness: {
      message: 409
    },
    format: {
      with: URI::MailTo::EMAIL_REGEXP,
      message: "is invalid."
    }
  }

  validates :password, {
    format: {
      with: ValidationRegexps::PASSWORD,
      message: "needs min. 8 chars: 1 number, 1 upper, 1 lower, 1 special."
    }
  }

  private def create_root_folder
    Folder.create(user_id: self.id, level: Folder::ROOT[:level], name: Folder::ROOT[:name])
  end

  def root_folder
    self.folders.find_by(level: Folder::ROOT[:level])
  rescue ActiveRecord::RecordNotFound
    raise MissingRootFolder
  end

  def find_owned(model_name, id)
    class_name = model_name.to_s.classify.constantize
    class_name.find_by!(id: id, user: self)
  rescue ActiveRecord::RecordNotFound
    raise NotFound(class_name)
  end

end