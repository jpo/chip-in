require 'rubygems'
require 'sinatra'
require 'sinatra/json'
require 'stripe'

set :publishable_key, ENV['PUBLISHABLE_KEY'] || 'YOUR_PUBLISHABLE_KEY'
set :secret_key,      ENV['SECRET_KEY'] || 'YOUR_SECRET_KEY'

Stripe.api_key = settings.secret_key

get '/' do
  erb :index
end

post '/donate' do
  amount = params[:amount].to_i

  if amount > 0
    customer = Stripe::Customer.create({ :card => params[:stripeToken]})

    Stripe::Charge.create({
      :amount       =>  amount,
      :description  => 'Support Our Cause',
      :currency     => 'usd',
      :customer     => customer.id 
    })

    status 200
    body 'Thank you for your donation!'
  else
    status 500
    body 'Oops! Something went wrong, please try again.'
  end
end

error do
  env['sinatra.error'].message
  status 500
  body 'Oops! Something went wrong, please try again.'
end

__END__

@@index
<!DOCTYPE html>
<html xmlns="http://www.w3.org/1999/xhtml" xmlns:fb="http://ogp.me/ns/fb#">
<head>
  <meta charset="UTF-8">
  <meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
  <title>Chip In - Support Our Cause</title>
  <meta name="viewport" content="width=device-width, initial-scale=1.0"/>
  <link rel="stylesheet" href="css/bootstrap.css" type="text/css"/>
  <link rel="stylesheet" href="css/bootstrap-responsive.css" type="text/css"/>
  <link rel="stylesheet" href="css/toastr.min.css" type="text/css"/>
  <link rel="stylesheet" href="css/strip.css" type="text/css"/>
  <link rel="stylesheet" href="css/strip-responsive.css" type="text/css"/>
  <link href="https://fonts.googleapis.com/css?family=Open+Sans:400,300,700,600" rel="stylesheet"/>
  <link href='https://fonts.googleapis.com/css?family=Merriweather:400,700' rel='stylesheet' type='text/css'/>
</head>
<body id="top">
  <div class="container">
    <div class="navbar">
      <div class="navbar-inner">
        <div class="container">
          <ul class="nav nav-pills pull-right">
            <li><a href="#">Event</a></li>
            <li><a href="#">Flyer</a></li>
            <li><a href="#">Sponsors</a></li>
          </ul>
          <a href="/" class="brand">Chip In!</a>
        </div>
      </div>
    </div>
  </div>

  <div class="container">
      <div class="row">
          <div class="highlight span12">
              <h2><strong>Support Our Cause</strong></h2>
              <img id="feature-screenshot" src="http://placehold.it/740x280" alt="Featured Image">           
              <br/><br/>
              <form id="donation-form" class="form-inline" action="/donate" method="post">
                <select id="amount" name="amount">
                  <option value="0">Select Amount...</option>
                  <option value="100">$1 donation</option>
                  <option value="500">$5 donation</option>
                  <option value="1000">$10 donation</option>
                  <option value="2000">$20 donation</option>
                  <option value="5000">$50 donation</option>
                  <option value="10000">$100 donation</option>
                </select>
                <input class="btn btn-primary" type="submit" id="donate" value="Donate" />
              </form>
          </div>        
      </div>   
  </div>

  <div class="section-box shadow">
    <div class="container">
      <div class="row">
        <div class="highlight span10 offset1">
          <h3>About Our Cause</h3> 
          <div style="text-align: left">
            <p>
              Lorem ipsum dolor sit amet, consectetur adipiscing elit. Aliquam sit amet velit viverra, suscipit arcu ut, aliquam turpis. Ut justo quam, ultricies quis tempor a, dapibus id turpis. Curabitur ut pellentesque sem. Fusce fermentum quis ligula lacinia posuere. Nulla at leo tincidunt, tincidunt velit quis, sollicitudin felis. Suspendisse dignissim elementum lacus, ac venenatis elit egestas at. Nunc dapibus tellus eu risus consectetur, eu accumsan magna auctor. Donec rutrum nibh risus, in rhoncus magna dapibus consequat. Etiam scelerisque nulla a leo efficitur, eget elementum justo consectetur. Fusce vel consectetur sem, a feugiat justo. Cras id nunc vel turpis auctor tempor. Quisque vel metus ac est tristique faucibus.
            </p>
            <p>
              Nullam ultricies vestibulum nunc ac sodales. Sed vitae consectetur quam. Aenean at risus sit amet ante pharetra varius. Integer dignissim cursus porttitor. Maecenas eget est non turpis fringilla rhoncus. Morbi aliquam eget nibh ac hendrerit. Phasellus tristique auctor placerat. Nullam tristique est nec ex tincidunt dignissim. Class aptent taciti sociosqu ad litora torquent per conubia nostra, per inceptos himenaeos. Fusce in est ante. Curabitur et tincidunt sapien. Aenean quis fringilla ligula. Maecenas vitae diam vitae mi ornare varius.
            </p>
            <p>
              Morbi erat libero, bibendum et tincidunt eu, egestas non urna. Aliquam quis nibh vel mauris congue congue. Nullam bibendum augue a metus ultrices, eu viverra risus mattis. Vestibulum tellus sapien, lobortis a magna nec, consectetur volutpat quam. Nunc eget scelerisque mi. Phasellus ultrices scelerisque turpis, vitae interdum lectus. Vivamus mattis neque dolor, vel gravida enim volutpat eget.
            </p>
          </div>
        </div>
      </div>
    </div>
  </div>

  <div class="container footer-box">   
    <div class="links">             
      <a href="#top">Back To Top</a>
    </div>  
    <p>This site was created using <strong>Chip In!</strong></p>           
  </div>

  <script src="js/jquery-1.8.0.min.js" type="text/javascript"></script>
  <script src="js/bootstrap.js" type="text/javascript"></script>
  <script src="js/toastr.min.js" type="text/javascript"></script>
  <script src="https://checkout.stripe.com/v2/checkout.js" type="text/javascript"></script>

  <script type="text/javascript">
    $(document).ready(function() {
      $('#donation-form').submit(function(e) {
        var url    = $(this).attr('action'),
            amount = $('#amount').val();

        var token = function(res) {
          var saving = toastr.info("We're saving your donation...", "Please Wait", { timeOut: 0 });
          $.ajax({
            type: "POST",
            url: url,
            data: { amount: amount, stripeToken: res.id },
            success: function() { 
              toastr.clear(saving);
              toastr.success('Your donation has been saved.', 'Thank you!'); 
            },
            error: function() { 
              toastr.clear(saving);
              toastr.error('Please try again.', 'Oops! Something went wrong.'); 
            }
          });
        };

        StripeCheckout.open({
          key:         '<%= settings.publishable_key %>',
          name:        'Chip In',
          amount:      parseInt(amount),
          currency:    'usd',
          panelLabel:  'Donate',
          token:       token
        });

        e.preventDefault();
      });
    });
  </script>
</body>
</html>
