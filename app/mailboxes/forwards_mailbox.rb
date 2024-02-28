class ForwardsMailbox < ApplicationMailbox
  def process
    puts "\n\n\n\n ############################## TEST DE MAILBOX ####################\n\n"
    # puts mail
    # Rails.logger.info "\n\n\n\n ########## Tes de mailbox ##################################################\n\n"
    # Rails.logger.info mail.subject
    # Rails.logger.info mail.body.decoded
    prompt = mail.body.raw_source

    puts "\n\n ===============>raw_source class: #{prompt.class.name}"
    puts "\n\n ===============>raw_source: #{prompt}"
    puts "\n\n ===============>fin"
    service = OpenaiService.new
    service.generate_response(mail.from[0], prompt)
  end
end
