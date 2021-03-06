#!/usr/bin/env ruby

# Use this script to update the resources recognized in syntax/terraform.vim.
# You'll need a current checkout of the Terraform source.

resource_declaration = /"(.*)":.*resource.*\(\),$/
syntax_file = 'syntax/terraform.vim'

# Specify the location of the Terraform source as the only argument to this
# script.
raise 'Please specify the location of the Terraform source.' if ARGV.empty?

# Create the list of resources.
provider_files = Dir.glob("#{ARGV[0]}/builtin/providers/*/*provider.go")
resources = provider_files.collect do |f|
  File.open(f, 'r').readlines.collect do |l|
    match = resource_declaration.match(l)
    "          \\ #{match[1]}\n" if match
  end.reject(&:nil?)
end.flatten.sort

# Read in the existing syntax file.
syntax = File.open(syntax_file, 'r').readlines

# Replace the terraResourceTypeBI lines with our new list.
first = syntax.index { |l| /^syn keyword terraResourceTypeBI/.match(l) } + 1
last = syntax.index { |l| /^""" end resources/.match(l) }
syntax.slice!(first, last - first)
resources.reverse_each do |r|
  syntax.insert(first, r)
end

# Write the syntax file back out.
File.open(syntax_file, 'w') do |f|
  f.puts syntax
end
