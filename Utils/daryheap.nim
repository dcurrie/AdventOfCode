#
#  Derived from heapqueue.nim:
#
#            Nim's Runtime Library
#        (c) Copyright 2016 Yuriy Glukhov
#
#    See the file "copying.txt", included in this
#    distribution, for details about the copyright.

##[
  The `daryheap` module implements a
  `D-ary heap data structure<https://en.wikipedia.org/wiki/D-ary_heap)>`_
  that can be used as a
  `priority queue<https://en.wikipedia.org/wiki/Priority_queue>`_.
  Heaps are arrays for which `a[k] <= a[D*k+1]` and `a[k] <= a[D*k+D]` for
  all `k`, counting elements from 0. The interesting property of a heap is that
  `a[0]` is always its smallest element.
  Note that if `D` is 2, `daryheap` implements a binary heap.
  The `daryheap` maintains a heap of reference objects; the index of each reference object
  in the heap is maintained in the object's `index` field. This facilitates use with the 
  Dijkstra shortest path graph algorithm, which needs the index in constant time for the
  `decrease-priority` operation.
  
  Basic usage
  -----------
  .. code-block:: Nim
    import daryheap
    var heap = initDaryHeap[GNode](4)
    heap.push(GNode(priority: 8))
    heap.push(GNode(priority: 2))
    heap.push(GNode(priority: 5))
    # The first element is the lowest element
    assert heap.data[0].priority == 2
    # Remove and return the lowest element
    assert heap.pop().priority == 2
    # The lowest element remaining is 5
    assert heap.data[0].priority == 5
  Usage with custom object
  ------------------------
  To use a `DaryHeap` with a custom object, the `<` operator must be
  implemented, and the object must have a settable `index` field.
  
  .. code-block:: Nim
    import daryheap
    type Job = ref object
      priority*: int
      index*: int
    proc `<`*(a, b: Job): bool = a.priority < b.priority
    proc `index=`*(x: var Job, value: int) {.inline.} = x.index = value
    var jobs = initDaryHeap[Job](4)
    jobs.push(Job(priority: 1))
    jobs.push(Job(priority: 2))
    assert jobs[0].priority == 1
]##

type DaryHeap*[T] = object
  ## A d-ary heap implementing a priority queue.
  d: int # the fanout of the heap
  data: seq[T]

proc initDaryHeap*[T](d: int): DaryHeap[T] =
  ## Create a new empty heap.
  result.d = d

proc len*[T](heap: DaryHeap[T]): int {.inline.} =
  ## Return the number of elements of `heap`.
  heap.data.len

proc `[]`*[T](heap: DaryHeap[T], i: Natural): T {.inline.} =
  ## Access the i-th element of `heap`.
  heap.data[i]

proc heapCmp[T](x, y: T): bool {.inline.} =
  return (x < y)

proc siftdown[T](heap: var DaryHeap[T], startpos, p: int) =
  ## 'heap' is a heap at all indices >= startpos, except possibly for pos.  pos
  ## is the index of a leaf with a possibly out-of-order value.  Restore the
  ## heap invariant.
  #echo("siftdown ", startpos, " ", p)
  var pos = p
  var newitem = heap.data[pos]
  #newitem.index = pos # taken care of below
  # Follow the path to the root, moving parents down until finding a place
  # newitem fits.
  while pos > startpos:
    let parentpos = (pos - 1) /% heap.d # floor
    var parent = heap.data[parentpos]
    if heapCmp(newitem, parent):
      heap.data[pos] = parent
      parent.index = pos
      pos = parentpos
    else:
      break
  heap.data[pos] = newitem
  newitem.index = pos

proc siftup[T](heap: var DaryHeap[T], p: int) =
  #echo("siftup   ", p)
  let endpos = len(heap)
  var pos = p
  let startpos = pos
  var newitem = heap.data[pos]
  # Bubble up the smaller child until hitting a leaf.
  var childpos = heap.d * pos + 1 # leftmost child position
  while childpos < endpos:
    # Set childpos to index of smallest child.
    let dpos = childpos + heap.d
    var rightpos = childpos + 1
    while rightpos < dpos and rightpos < endpos:
      if not heapCmp(heap.data[childpos], heap.data[rightpos]):
        childpos = rightpos
      rightpos = rightpos + 1
    # Move the smallest child up.
    heap.data[pos] = heap.data[childpos]
    heap.data[pos].index = pos
    pos = childpos
    childpos = heap.d * pos + 1
  # The leaf at pos is empty now.  Put newitem there, and bubble it up
  # to its final resting place (by sifting its parents down).
  heap.data[pos] = newitem
  #newItem.index = pos # done by siftdown
  siftdown(heap, startpos, pos)

proc push*[T](heap: var DaryHeap[T], item: T) =
  ## Push `item` onto heap, maintaining the heap invariant.
  heap.data.add(item)
  siftdown(heap, 0, len(heap)-1)

proc pop*[T](heap: var DaryHeap[T]): T =
  ## Pop and return the smallest item from `heap`,
  ## maintaining the heap invariant.
  var lastelt = heap.data.pop()
  if heap.len > 0:
    result = heap.data[0]
    heap.data[0] = lastelt
    #lastelt.index = 0
    siftup(heap, 0)
  else:
    result = lastelt

proc del*[T](heap: var DaryHeap[T], index: Natural) =
  #echo("** del ", index)
  ## Removes the element at `index` from `heap`, maintaining the heap invariant.
  swap(heap.data[^1], heap.data[index])
  heap.data[index].index = index
  let newLen = heap.len - 1
  heap.data.setLen(newLen)
  if index < newLen:
    heap.siftup(index)

proc replace*[T](heap: var DaryHeap[T], item: T): T =
  ## Pop and return the current smallest value, and add the new item.
  ## This is more efficient than pop() followed by push(), and can be
  ## more appropriate when using a fixed-size heap. Note that the value
  ## returned may be larger than item! That constrains reasonable uses of
  ## this routine unless written as part of a conditional replacement:
  ##
  ## .. code-block:: nim
  ##    if item > heap.data[0]:
  ##        item = replace(heap, item)
  result = heap.data[0]
  heap.data[0] = item
  item.index = 0
  siftup(heap, 0)

proc pushpop*[T](heap: var DaryHeap[T], item: T): T =
  ## Fast version of a push followed by a pop.
  if heap.len > 0 and heapCmp(heap.data[0], item):
    swap(item, heap.data[0])
    heap.data[0].index = 0
    siftup(heap, 0)
  return item

proc clear*[T](heap: var DaryHeap[T]) =
  ## Remove all elements from `heap`, making it empty.
  runnableExamples:
    type Job = ref object
      priority*: int
      index*: int
    proc `<`*(a, b: Job): bool = a.priority < b.priority
    proc `index=`*(x: var Job, value: int) {.inline.} = x.index = value
    var jobs = initDaryHeap[Job](4)
    jobs.push(Job(priority: 1))
    jobs.clear()
    assert jobs.len == 0
  heap.data.setLen(0)

proc `$`*[T](heap: DaryHeap[T]): string =
  ## Turn a heap into its string representation.
  runnableExamples:
    type Job = ref object
      priority*: int
      index*: int
    proc `<`*(a, b: Job): bool = a.priority < b.priority
    proc `index=`*(x: var Job, value: int) {.inline.} = x.index = value
    proc `$`*(x: Job): string = $x.priority
    var jobs = initDaryHeap[Job](4)
    jobs.push(Job(priority: 1))
    jobs.push(Job(priority: 2))
    assert $jobs == "[1, 2]"
  result = "["
  for x in heap.data:
    if result.len > 1: result.add(", ")
    result.addQuoted(x)
  result.add("]")


when isMainModule:
  type
    GNode = ref object
      priority*: int
      index*: int

  proc `<`*(a, b: GNode): bool = a.priority < b.priority

  proc `index=`*(x: var GNode, value: int) {.inline.} =
      x.index = value

  proc `==`*(a, b: GNode): bool = a.priority == b.priority

  proc toSortedSeq[T](h: DaryHeap[T]): seq[int] =
    var tmp = deepCopy[DaryHeap[T]](h)
    result = @[]
    while tmp.len > 0:
      result.add(pop(tmp).priority)

  proc testIndices[T](h: DaryHeap[T]): bool =
    var i = 0
    #echo("")
    while i < h.data.len:
      #echo(i, " ", h.data[i].priority, " ", h.data[i].index)
      doAssert(h.data[i].index == i)
      i = i + 1
    result = true

  block: # Simple sanity test
    var heap = initDaryHeap[GNode](4)
    let data = [1, 3, 5, 7, 9, 2, 4, 6, 8, 0]
    for item in data:
      push(heap, GNode(priority: item)) #, index: -1
    doAssert(heap.data[0].priority == 0)
    doAssert(heap.testIndices())
    doAssert(heap.toSortedSeq == @[0, 1, 2, 3, 4, 5, 6, 7, 8, 9])

  block: # Test del
    var heap = initDaryHeap[GNode](4)
    let data = [1, 3, 5, 7, 9, 2, 4, 6, 8, 0]
    for item in data: push(heap, GNode(priority: item))

    heap.del(0)
    doAssert(heap.testIndices())
    doAssert(heap.data[0].priority == 1)

    heap.del(heap.data.find(GNode(priority: 7)))
    doAssert(heap.testIndices())
    doAssert(heap.toSortedSeq == @[1, 2, 3, 4, 5, 6, 8, 9])

    heap.del(heap.data.find(GNode(priority: 5)))
    doAssert(heap.testIndices())
    doAssert(heap.toSortedSeq == @[1, 2, 3, 4, 6, 8, 9])

    heap.del(heap.data.find(GNode(priority: 6)))
    doAssert(heap.testIndices())
    doAssert(heap.toSortedSeq == @[1, 2, 3, 4, 8, 9])

    heap.del(heap.data.find(GNode(priority: 2)))
    doAssert(heap.testIndices())
    doAssert(heap.toSortedSeq == @[1, 3, 4, 8, 9])

  block: # Test del last
    var heap = initDaryHeap[GNode](4)
    let data = [1, 2, 3]
    for item in data: push(heap, GNode(priority: item))

    # echo(heap)

    heap.del(2)
    doAssert(heap.toSortedSeq == @[1, 2])

    heap.del(1)
    doAssert(heap.toSortedSeq == @[1])

    heap.del(0)
    doAssert(heap.toSortedSeq == @[])