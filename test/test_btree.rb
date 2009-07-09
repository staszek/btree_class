require "test/unit"
require "lib/btree.rb"

class TestBTree < Test::Unit::TestCase


  # Setup tree:
  #                0
  #           [4,8,12,16]
  #   //    /     |      \       \\
  #   1     2     3      4        5
  # [1,2] [5,6] [9,10] [13,14] [17,18]
  #
  def setup
    @tree = BTree.new
    @tree.nodes << Node.new(@tree.id, :values => [4, 8, 12, 16])
    @tree.nodes << Node.new(@tree.id, :parent => 0, :values => [1, 2], :position => 0)
    @tree.nodes << Node.new(@tree.id, :parent => 0, :values => [5, 6], :position => 1)
    @tree.nodes << Node.new(@tree.id, :parent => 0, :values => [9, 10], :position => 2)
    @tree.nodes << Node.new(@tree.id, :parent => 0, :values => [13, 14], :position => 3)
    @tree.nodes << Node.new(@tree.id, :parent => 0, :values => [17, 18], :position => 4)
  end
  
  def test_node_initialize
    root_parent = Node.new(0)
    five_parent = Node.new(0, :parent => 5)
    empty = Node.new(0)
    unsort = Node.new(0, :values => [5, 2, 7, 11, 9])
    
    assert_equal nil, root_parent.parent
    assert_equal 5, five_parent.parent
    assert_equal [], empty.items
    assert_equal [2, 5, 7, 9, 11], unsort.items
  end

  def test_node_actions
    node = Node.new(0, :values => [11, 12, 14])
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

  def test_subtree
    node = Node.new(0, :values => [2, 5, 10])
    assert_equal 0, node.subtree(1)
    assert_equal 1, node.subtree(3)
    assert_equal 3, node.subtree(11)
    assert_equal false, node.subtree(5)
  end

  def test_is_leaf
    assert_equal true, @tree.leaf?(3)
    assert_equal false, @tree.leaf?(0)
  end

  def test_finding_node
    assert_equal @tree.nodes[1], @tree.find_node(0, 0)
    assert_equal nil, @tree.find_node(1, 1)
  end

  def test_finding_leaf
    assert_equal 1, @tree.find_leaf(3)
    assert_equal 3, @tree.find_leaf(11)
    assert_equal 5, @tree.find_leaf(20)
  end

end



