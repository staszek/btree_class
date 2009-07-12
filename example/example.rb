# == btree_class example
# Stanislaw Kolarzowski 2009
#
# Program allow user to create and manage B-tree
# Type command into console
#
# Commands:
#   +number => Insert value to tree
#   -number => Delete value from tree
#   number  => Find value in tree
#   >number => Return next value in tree
#   first   => Return first value in tree
#   all     => Return all values in tree
#   quit    => Quit
#   show    => Show tree

require "lib/btree.rb"


def show_node(tree, node)
  print "ID:#{node.id} Parent:#{node.parent}      Keys:"
  node.keys.each { |key| print "[#{key}]"}
  print " Sub trees:"
  node.sub_trees.each { |sub_tree| print "-#{sub_tree}-"}
  print "\n"
  node.sub_trees.compact.each { |sub_tree| show_node(tree, tree.nodes[sub_tree])}
end


# MAIN
tree = BTree.new :n => 3

command = ""
while (command!="q")
  print ">>"
  str = gets
  str.chomp!
  command = str[0,1]
  number = str[/\d+/].to_i

  case command
    when "+"
      puts "Value is already in tree" if tree.insert_value(number)==false
    when "-"
      puts "Value is not in tree" if tree.delete_value(number)==false
    when ">"
      next_value = tree.next(number)
      if next_value==false then puts "Can't find next value" else puts next_value end
    when "f"
      first_value = tree.first_value
      if first_value==false then puts "Tree is empty" else puts first_value end
    when "a"
      value = tree.first_value
      values = []
      while (value!=false)
        values << value
        value = tree.next(value)
      end
      if values.size>0 then puts values else puts "Tree is empty" end
    when "s"
      show_node(tree, tree.nodes[tree.root])
    when "q"
      puts "Bye"
  else
    if tree.find_value(number)[:find]==true then puts "Value found" else puts "Value not found" end
  end
end