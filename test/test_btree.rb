require "test/unit"
require "lib/btree.rb"

class TestBTree < Test::Unit::TestCase


  # Setup tree:
  #             0
  #         [6,12,18]
  #   //    /     \     \\
  #   1     2     3      4
  # [1,2] [7,8] [13,14] [19,20]
  #
  def setup
    @tree = BTree.new
    @tree.add(Node.new(:values => [6, 12, 18]))
    @tree.add(Node.new(:parent => 0, :values => [1, 2], :position => 0))
    @tree.add(Node.new(:parent => 0, :values => [7, 8], :position => 1))
    @tree.add(Node.new(:parent => 0, :values => [13, 14], :position => 2))
    @tree.add(Node.new(:parent => 0, :values => [19, 20], :position => 3))
  end
  
  def test_node_initialize
    root_parent = Node.new
    five_parent = Node.new(:parent => 5)
    empty = Node.new
    unsort = Node.new(:values => [5, 2, 7, 11, 9])
    
    assert_equal nil, root_parent.parent
    assert_equal 5, five_parent.parent
    assert_equal [], empty.items
    assert_equal [2, 5, 7, 9, 11], unsort.items
  end

  def test_node_actions
    node = Node.new(:values => [11, 12, 14])
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
    node = Node.new(:values => [2, 5, 10])
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
    assert_equal 3, @tree.find_leaf(15)
    assert_equal 4, @tree.find_leaf(27)
  end

  def test_searching
    all_nodes = @tree.nodes.all? do |node|
      node.items.all? { |item| @tree.find_value(item) }
    end
    assert_equal true, all_nodes
    assert_equal false, @tree.find_value(40)
  end

  def test_changing_position
    @tree.change_position(@tree.nodes[0], 2)
    assert_equal 0, @tree.nodes[1].position
    assert_equal 1, @tree.nodes[2].position
    assert_equal 3, @tree.nodes[3].position
  end

  def test_insert
    @tree.insert_value(9)
    @tree.insert_value(10)
    assert_equal [7, 8, 9, 10], @tree.nodes[2].items
    
    @tree.insert_value(11)
    assert_equal [6, 9, 12, 18], @tree.nodes[0].items
    assert_equal [1, 2], @tree.find_node(0, 0).items
    assert_equal [7, 8], @tree.find_node(0, 1).items
    assert_equal [10, 11], @tree.find_node(0, 2).items
    assert_equal [13, 14], @tree.find_node(0, 3).items


  end



end



