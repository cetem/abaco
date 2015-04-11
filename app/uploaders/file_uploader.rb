# encoding: utf-8

class FileUploader < CarrierWave::Uploader::Base
  storage :file

  def store_dir
    model_id = ('%09d' % model.id).scan(/\d{3}/).join('/')

    "private/#{model.class.to_s.underscore}/#{mounted_as}/#{model_id}"
  end

  def extension_white_list
    %w(jpg jpeg gif png pdf)
  end
end
