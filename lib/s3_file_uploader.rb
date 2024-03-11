class S3FileUploader
  def initialize
    @s3 = Aws::S3::Client.new
  end

  def save_file_to_s3(filename, csv)
    @s3.put_object({
      bucket: ENV["AWS_S3_BUCKET_NAME"],
      key: filename,
      content_type: "text/csv",
      body: csv,
    })
  end
end
