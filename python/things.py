# things.py

# Let's get this party started
import falcon
import sys


# Falcon follows the REST architectural style, meaning (among
# other things) that you think in terms of resources and state
# transitions, which map to HTTP verbs.
class ThingsResource:
	def on_get(self, req, resp):
		"""Handles GET requests"""
		resp.status = falcon.HTTP_200  # This is the default status
                print("Received: " + req.query_string)
		sys.stdout.flush()
		resp.body = ('{ "text" : "Hello World"}')
		
	def on_post(self, req, resp):
		msg = ""
		while True:
			chunk = req.stream.read(4096)
			if not chunk:
				break
			msg += str(chunk)
		print("Received: " + msg)
		resp.status = falcon.HTTP_201

# falcon.API instances are callable WSGI apps
app = falcon.API()

# Resources are represented by long-lived class instances
things = ThingsResource()

# things will handle all requests to the '/things' URL path
app.add_route('/things', things)
