# frozen_string_literal: true

module Spotlight
  ##
  # Process a CSV upload into new Spotlight::Resource::Upload objects
  class AddUploadsFromCSV < ActiveJob::Base
    queue_as :default

    after_perform do |job|
      csv_data, exhibit, user = job.arguments
      Spotlight::IndexingCompleteMailer.documents_indexed(csv_data, exhibit, user).deliver_now
    end

    def perform(csv_data, exhibit, _user)
      Rails.logger.info "HACK AddUploadsFromCSV"
      encoded_csv(csv_data).each do |row|
        Rails.logger.info "HACK row: #{row}"
        url = row.delete('url')
        Rails.logger.info "HACK url: #{url}"
        next unless url.present?
        Rails.logger.info "HACK url present: #{url.present?}"
        resource = Spotlight::Resources::Upload.new(
          data: row,
          exhibit: exhibit
        )
        resource.build_upload(remote_image_url: url) unless url == '~'
        Rails.logger.info "HACK url present: before resource.save_and_index"
        resource.save_and_index
        Rails.logger.info "HACK url present: after resource.save_and_index"
      end
    end

    private

    def encoded_csv(csv)
      csv.map do |row|
        row.map do |label, column|
          [label, column.encode('UTF-8', invalid: :replace, undef: :replace, replace: "\uFFFD")] if column.present?
        end.compact.to_h
      end.compact
    end
  end
end
