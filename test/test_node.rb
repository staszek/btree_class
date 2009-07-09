require "test/unit"
require "lib/btree.rb"

class TestBTree < Test::Unit::TestCase


  # Setup tree:
  #             0
  #         [5,10,15]
  #   //    /     \     \\
  #   1     ?     2      3
  # [1,2]  [] [11,14] [20,40]
  #
  def setup
    @root_node = Node.new([5, 10, 15])
    @first_node = Node.new([1, 2])
    @third_node = Node.new([11, 14])
    @last_node = Node.new([20, 40])

    @root_node.id = 0
    @first_node.id = 1
    @third_node.id = 2
    @last_node.id = 3

    @root_node.add_sub_tree(@first_node)
    @root_node.add_sub_tree(@third_node)
    @root_node.add_sub_tree(@last_node)
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

  def test_find_subtree
    assert_equal 0, @root_node.find_subtree(3)
    assert_equal 2, @root_node.find_subtree(12)
    assert_equal 3, @root_node.find_subtree(20)
    assert_equal false, @root_node.find_subtree(15)
  end

  def test_add_sub_trees
    false_node = Node.new([7, 12])
    include_node = Node.new([5, 7])
    include_other_node = Node.new([6, 10])

    false_node.id = 4
    include_node.id = 5
    include_other_node.id = 6

    assert_equal 1, @root_node.sub_trees[0]
    assert_equal nil, @root_node.sub_trees[1]
    assert_equal 2, @root_node.sub_trees[2]
    assert_equal 3, @root_node.sub_trees[3]
    assert_equal 0, @last_node.parent
    assert_equal false, @root_node.add_sub_tree(false_node)
    assert_equal false, @root_node.add_sub_tree(include_node)
    assert_equal false, @root_node.add_sub_tree(include_other_node)
  end

  def test_node_add
    assert_equal true, @root_node.add(8)
    assert_equal [1, nil, nil, 2, 3], @root_node.sub_trees
    assert_equal false, @root_node.add(2)
    assert_equal [nil, nil, nil, nil, 2, 3], @root_node.sub_trees
    assert_equal false, @root_node.add(16)
    assert_equal [nil, nil, nil, nil, 2, nil, nil], @root_node.sub_trees
    assert_equal [2, 5, 8, 10, 15, 16], @root_node.keys
  end

  def test_leaf?
    assert_equal true, @first_node.leaf?
    assert_equal false, @root_node.leaf?
  end


end



