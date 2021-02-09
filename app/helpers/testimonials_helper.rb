module TestimonialsHelper
	def upload_at_fb(testimonial)
    begin
      message = testimonial.text
      media_string = ''
      uri = URI.parse("https://graph.facebook.com/#{@current_community.fb_page_id}/photos")
      request = Net::HTTP::Post.new(uri)
      request.set_form_data(
        "access_token" => "#{@current_community.fb_access_id}",
        "published" => "false",
        "url" => Rails.env.eql?('development') ? "http://localhost:3000#{image_url 'share_review.png'}" : "https://suppersocial.co#{image_url 'share_review.png'}",
      )
      req_options = {
        use_ssl: uri.scheme == "https",
      }
      response = Net::HTTP.start(uri.hostname, uri.port, req_options) do |http|
        http.request(request)
      end
      if response.code == "200"
        photo_id = JSON.parse(response.body)['id'] rescue nil
        if photo_id.present?
          media_string = media_string+"&attached_media[#{i}]={media_fbid:#{photo_id}}"
          i = i+1
        end
      end



      uri = URI.parse("https://graph.facebook.com/#{@current_community.fb_page_id}/feed")
      request = Net::HTTP::Post.new(uri)
      message = CGI.escape(message)
      if media_string.present?
        request_body = "message=#{message}"+media_string+"&access_token=#{@current_community.fb_access_id}&published=true"
      else
        request_body = "message=#{message}&access_token=#{@current_community.fb_access_id}&published=true"
      end
      request.body = request_body
      req_options = {
        use_ssl: uri.scheme == "https",
      }
      response = Net::HTTP.start(uri.hostname, uri.port, req_options) do |http|
        http.request(request)
      end
      result = JSON.parse(response.body)
      unless result['id'].present?
      end
    rescue Exception => e
      #Bugsnag.notify(e.message)
      #flash[:notice] = e.message
    end
  end
end
