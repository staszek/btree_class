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
    @tree.add(Node.new([6, 12, 18]))
    @tree.add(Node.new([1, 2]))
    @tree.add(Node.new([7, 8]))
    @tree.add(Node.new([13, 14]))
    @tree.add(Node.new([19, 20]))
    @tree.add_sub_trees(0, [1, 2, 3, 4])
  end

  def test_searching
    all_nodes = @tree.nodes.all? do |node|
      node.keys.all? { |item| @tree.find_value(item) }
    end
    assert_equal true, all_nodes
    assert_not_equal true, @tree.find_value(24)
  end

  def test_insert
    @tree.insert_value(21)
    @tree.insert_value(22)
    assert_equal [19, 20, 21, 22], @tree.nodes[4].keys
    assert_equal false, @tree.insert_value(20)

    @small_tree = BTree.new(:n => 3)
    @small_tree.add(Node.new([4]))
    @small_tree.add(Node.new([2]))
    @small_tree.add(Node.new([6, 8]))
    @small_tree.add(Node.new([1]))
    @small_tree.add(Node.new([3]))
    @small_tree.add(Node.new([5]))
    @small_tree.add(Node.new([7]))
    @small_tree.add(Node.new([9, 10]))
    @small_tree.add_sub_trees(0, [1, 2])
    @small_tree.add_sub_trees(1, [3, 4])
    @small_tree.add_sub_trees(2, [5, 6, 7])

    @small_tree.insert_value(11)
    @small_tree.insert_value(12)
    @small_tree.insert_value(13)
    @small_tree.insert_value(14)
    @small_tree.insert_value(15)

    assert_tree(@small_tree)
    @small_tree.add(Node.new([50,51,52,52,54]))
    assert_not_tree(@small_tree)
  end

  def check_tree(tree)
    nodes = tree.nodes.collect { |node| node if node.id>=0  }
    nodes.compact!
    size = nodes.all? do |node|
      node.size>=tree.min && node.size<=tree.max
    end
    val = nodes.all? do |node|
      less, greater = [], []
      node.sub_trees.each_with_index do |sub_tree, index|
        less << ( tree.nodes[sub_tree].right < node.keys[index] if index<node.size && !sub_tree.nil? )
        greater << ( tree.nodes[sub_tree].left > node.keys[index-1] if index>0 && !sub_tree.nil? )
      end
      less.compact!.delete(false).nil? && greater.compact!.delete(false).nil?
    end
    size && val
  end

  def assert_tree(tree)
    if check_tree(tree) then assert(true) else assert(false) end
  end

  def assert_not_tree(tree)
    unless check_tree(tree) then assert(true) else assert(false) end
  end



end



