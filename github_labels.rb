#!/usr/bin/env ruby

require 'octokit'

access_token = ARGV[0]
repo = ARGV[1]

if repo == nil || access_token == nil 
  abort "Usage: github_labels github-token-goes-here org/repo"
end

time_estimate_labels = {
  '0.5h' => {:color=>'ddddff'},
  '1h' => {:color=>'d4c5f9'},
  '2h' => {:color=>'bfd4f2'},
  '4h' => {:color=>'c7def8'},
  '8h' => {:color=>'bfe5bf'},
  '16h' => {:color=>'fef2c0'},
  '32h' => {:color=>'fad8c7'},
  '64h' => {:color=>'f7c6c7'},
  'Priority 1 Low' => {:color=>'fbca04'},
  'Priority 2 Medium' => {:color=>'eb6420'},
  'Priority 3 High' => {:color=>'e11d21'}
}

missing_time_estimate_labels = time_estimate_labels.clone

client = Octokit::Client.new(:access_token => access_token)
client.auto_paginate = true
labels = client.labels repo

labels.each do |label|
  label_name = label[:name]
  updated_label = missing_time_estimate_labels[label_name]
  if updated_label != nil
    client.update_label repo, label_name, updated_label
    missing_time_estimate_labels.delete(label_name)
  end
end

missing_time_estimate_labels.each do |name, label|
  client.add_label repo, name, label[:color], label
end