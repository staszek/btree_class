require "test/unit"
require "lib/btree.rb"

class TestBTree < Test::Unit::TestCase
  def test_node_initialize
    root_parent = Node.new
    five_parent = Node.new(5)
    empty = Node.new
    unsort = Node.new(0, [5, 2, 7, 11, 9])
    
    assert_equal nil, root_parent.parent
    assert_equal 5, five_parent.parent
    assert_equal [], empty.items
    assert_equal [2, 5, 7, 9, 11], unsort.items
  end

  def test_node_actions
    node = Node.new(0, [11, 12, 14])
    assert_equal 3, node.size
    assert_equal 11, node.left
    assert_equal 14, node.right

    node.add(14)
    assert_equal 3, node.size
    node.add(13)
    assert_equal 4, node.size
    assert_equal 14, node.right

    node.delete(10)
    assert_equal 4, node.size
    node.delete(14)
    assert_equal 3, node.size
  end
end



