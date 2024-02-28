# README

This is a monolithic application with Action Mailbox and SendGrid integration.

This application will allow us to route the incoming emails to controllers-like for processing.

The inbound emails are turned into Inbound Email records using Active Record and feature lifecycle tracking and storage of the original email on cloud storage via Active Storage.


### Step 1: Setup action mailbox

```ruby
 #Gemfile.yml
 gem 'sendgrid-ruby', '~> 6.7'
```

```sh
 $ bundle install
 $ bin/rails action_mailbox:install
 $ bin/rails db:migrate

```


### Step 2: Ingress Configuration

```ruby
# config/environments/development.rb || config/environments/production.rb
config.action_mailbox.ingress = :sendgrid
config.hosts << 'yoursite.com'

```


### Step 3: Generate Password for authenticating requests and set the credentials

Generate a secure password

```sh
    rails c
    SecureRandom.alphanumeric
    # => "Hng7pRE9K5ztqZMI"
```

After that, add that password to your application’s encrypted as follows.

 ```sh
    EDITOR="vim" bin/rails credentials:edit
 ```

 ```ruby
 action_mailbox:
  ingress_password: <GENERATED_PASSWORD>

 ```

### Step 4: Setup a mailbox

Generate the mailbox controller where emails will be processed

```ruby
# Generate new mailbox
$ bin/rails generate mailbox forwards
```

```ruby
  # app/mailboxes/forwards_mailbox.rb
  class ForwardsMailbox < ApplicationMailbox
    # Callbacks specify prerequisites to processing

    def process
      # process the emails
      #  puts "From: #{mail.from}"
      #  puts "To: #{mail.to}"
      #  puts "Body: #{mail.body}"

      # do stuff
    end
  end
```

### Step 5: Configure basic routing
Configuring our application_mailbox to accept all incoming emails

```ruby
# app/mailboxes/application_mailbox.rb
class ApplicationMailbox < ActionMailbox::Base
  # Accept from any domains
  routing all: :forwards

  # Accept emails from an specific single email account
  # routing /info@email-domain.com/i => :forwards

  # Accept all emails from single domain
  #routing /.*@email-domain.com/i => :forwards

  # Accept email from multiple domains
  # routing /.*@primary-email-domain.com|.*@secondary-email-domain.com/i => :forwards
end
```

### Step 6: Test in development

There's a conductor controller mounted at /rails/conductor/action_mailbox/inbound_emails, which gives you an index of all the Inbound Emails in the system

Click on New inbound email by form. Fill in all required details like From, To, Subject and Body. You can leave other fields blank.

Before clicking on Deliver inbound email, let’s add byebug (or any other debugging breakpoint e.g. binding.pry)

```ruby
  # app/mailboxes/forwards_mailbox.rb
  class ForwardsMailbox < ApplicationMailbox
    def process
      byebug
    end
  end
```


### Step 8: Authenticate domain in SendGrid to test Live


Start by logging in to your SendGrid account. In the left-side navigation bar, click on “Settings” and then select Sender Authentication.

<img width="347" alt="p1-sendgrid-sidebar-sender-auth" src="https://github.com/bj-koombea/hermes/assets/93946548/0890d984-8944-4533-af0a-f92ec64cee54">


On the Sender Authentication page, click the “Get Started” button in the “Domain Authentication” section.

<img width="1127" alt="p2" src="https://github.com/bj-koombea/hermes/assets/93946548/7f0e6193-dd91-4557-ae0a-282ae1a44b0d">


Here, in the first prompt, you need to select your DNS provider, which in most cases is the company from which you purchased the domain. Click on Next to continue

<img width="1377" alt="p3" src="https://github.com/bj-koombea/hermes/assets/93946548/dafe18c8-2c4a-4a3c-b54b-0c6a2b60a54e">


On the next screen, you will be prompted to enter your domain name. In my case, I entered bjohnmer.com. You will need to enter your own domain name. Click on Next to continue

<img width="1279" alt="p4" src="https://github.com/bj-koombea/hermes/assets/93946548/22a2879f-4606-40c4-a3e5-3d18b29fb184">


SendGrid is now going to show you a list of DNS records that you will need to add to your domain. Each DNS record has a type, a host and a value. Don't close this page yet.

<img width="1374" alt="p5" src="https://github.com/bj-koombea/hermes/assets/93946548/3d8514b3-7860-4474-b3b8-9cec14579eb2">

After that, you have to go into your domain provider’s administration page to add these DNS records. For this instance, I used Cloudflare.

So here we are going to add those DNS records. One tricky aspect here is figuring out that you need to remove the domain name from the hosts provided by SendGrid, as it's shown in the following:

<img width="1520" alt="p6" src="https://github.com/bj-koombea/hermes/assets/93946548/76d99352-a65e-42f0-95ea-00be07548dd6">


Additionally I've added an extra record MX.

Then, return to the DNS list on the Sender Authentication page. Click on the checkbox "I've added these records" and click on the 'Verify' button.

If all goes well, a successful view will be shown

<img width="1432" alt="p7" src="https://github.com/bj-koombea/hermes/assets/93946548/e0513cee-42f4-4db6-8ef7-6cc02253b232">

### Step 9: Add a sender verification

Go back to the Sender Authentication page and click on the button 'Verify a Single Sender' in the Single Sender Verification section.

<img width="572" alt="ss-p1" src="https://github.com/bj-koombea/hermes/assets/93946548/7b13edeb-25b0-476e-9dd2-a0e104732a79">


Click on the button 'Create new Sender' and fill the form.

<img width="669" alt="ss-p2" src="https://github.com/bj-koombea/hermes/assets/93946548/9688b3d8-d241-41f6-a5a2-04f93bf19464">


After registering a single sender, it will receive an email to verify it. Click on 'Verify Single Sender' Button

<img width="637" alt="ss-p3" src="https://github.com/bj-koombea/hermes/assets/93946548/e40c7b64-9e9f-4a9b-b148-fd71fdcedbfc">

### Step 10: Configure the Inbound Parse

- In the left-side navigation bar, select Inbound Parse. Then, click on 'Add Host & URL'.

![ip-p0](https://github.com/bj-koombea/hermes/assets/93946548/614f4a09-48dd-4f64-8106-dd615cc37033)

<img width="1423" alt="ip-p1" src="https://github.com/bj-koombea/hermes/assets/93946548/2fe7642d-fd72-4adb-ae80-c2f8c3863971">

- You can add/leave the subdomain part as required. I have left it blank
- Under “Domain”, choose your domain name that you just verified
- Under the URL Destination we will need to build one and add it

  For example: 'https://actionmailbox:<GENERATED_PASSWORD>@<yoursite.com>/rails/action_mailbox/sendgrid/inbound_emails'

<img width="695" alt="ip-p2" src="https://github.com/bj-koombea/hermes/assets/93946548/de016a93-844f-453f-810f-4a3abba5f059">

### Step 10: Heroku domain
As I am using Heroku, I did some additional steps.

- I have to add my Cloudflare DNS to Namecheap in the custom DNS section. Then, I added the Heroku domain
to Cloudflare.


You can follow this tutorials:
- https://guides.rubyonrails.org/action_mailbox_basics.html#postfix
- https://prabinpoudel.com.np/articles/action-mailbox-with-sendgrid/
