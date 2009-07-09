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

  end
  
  def test_node
    empty_node = Node.new
    unsort_node = Node.new([1, 20, 15, 4])
   
    assert_equal [nil], empty_node.sub_trees
    assert_equal [], empty_node.keys
    assert_equal [nil, nil, nil, nil, nil], unsort_node.sub_trees
    assert_equal [1, 4 ,15, 20], unsort_node.keys
    assert_equal 4, unsort_node.size
    assert_equal 1, unsort_node.left
    assert_equal 20, unsort_node.right
  end

  def test_add_sub_trees
    root_node = Node.new([5, 10, 15])
    first_node = Node.new([1, 2])
    third_node = Node.new([11, 14])
    last_node = Node.new([20, 40])
    false_node = Node.new([7, 12])
    include_node = Node.new([5, 7])
    include_other_node = Node.new([6, 10])
    root_node.id = 0
    first_node.id = 1
    third_node.id = 2
    last_node.id = 3
    false_node.id = 4
    include_node.id = 5
    include_other_node.id = 6
    
    root_node.add_sub_tree(first_node)
    root_node.add_sub_tree(third_node)
    root_node.add_sub_tree(last_node)
    assert_equal 1, root_node.sub_trees[0]
    assert_equal nil, root_node.sub_trees[1]
    assert_equal 2, root_node.sub_trees[2]
    assert_equal 3, root_node.sub_trees[3]
    assert_equal 0, last_node.parent
    assert_equal false, root_node.add_sub_tree(false_node)
    assert_equal false, root_node.add_sub_tree(include_node)
    assert_equal false, root_node.add_sub_tree(include_other_node)
  end
  
  def test_node_add_delete
    root_node = Node.new([5, 10, 15])
    first_node = Node.new([1, 2, 3])
    last_node = Node.new([16, 17, 18])
    root_node.id = 0
    first_node.id = 1
    last_node.id = 2
    root_node.add_sub_tree(first_node)
    root_node.add_sub_tree(last_node)
    
    assert_equal true, root_node.add(8)
    assert_equal [1, nil, nil, nil, 2], root_node.sub_trees
    assert_equal false, root_node.add(2)
    assert_equal [nil, nil, nil, nil, nil, 2], root_node.sub_trees
    assert_equal false, root_node.add(16)
    assert_equal [nil, nil, nil, nil, nil, nil, nil], root_node.sub_trees
    assert_equal [2, 5, 8, 10, 15, 16], root_node.keys


  end

  def test_finding_node
    
  end

  def test_finding_leaf
    
  end

  def test_searching
   
  end

  def test_changing_position
   
  end

  def test_insert

  end



end



