# app/controllers/request_game_controller.rb:
# The 'categorise old requests' game
#
# Copyright (c) 2009 UK Citizens Online Democracy. All rights reserved.
# Email: francis@mysociety.org; WWW: http://www.mysociety.org/
#
# $Id: request_game_controller.rb,v 1.2 2009-06-23 13:52:25 francis Exp $

class RequestGameController < ApplicationController
    
    def play
        # XXX make sure they're logged in
        session[:request_game] = Time.now

        old = InfoRequest.find_old_unclassified(:conditions => ["prominence = 'normal'"], :age_in_days => 10)
        @missing = old.size
        @requests = old.sort_by{ rand }.slice(0..2)
    end

    # Requests similar to this one
    def stop
        session[:request_game] = nil
        flash[:notice] = 'Thank you for helping us keep the site tidy!'
        redirect_to frontpage_url
    end

end
