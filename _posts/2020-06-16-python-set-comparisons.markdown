---
layout: post
title:  'Python set comparisons'
date:   2020-06-16 17:15:00 +1000
categories: python
---

Today a colleague posted the following code snippet:

```
actual = set(["foo", "bar"] + [<other strings here>])  
expected = set(["bar", "foo"] + [<other strings here])
if not actual == expected: 
    print(f"Unexpected: {actual - expected}")
```

They were facing the occassional error of `Unexpected: set()` and felt a bit lost.

After originally thinking about the ordering and edge cases that could affect it somehow to cause the match to be True but also reduce to zero, I came to look at the subtraction and realised that this would happen when when all elements of `actual` exist within `expected`, but `expected` also has additional values. 

For example:

```
>>> actual = set(["bar", "foo"])
>>> expected = set(['foo', 'bar', 'car'])
>>> actual == expected
False
>>> actual - expected
set()
```

Whereas if that was reversed, you get the additional value within `actual`, as it was never subtracted away:

```
>>> actual = set(['foo', 'bar', 'car'])
>>> expected = set(["bar", "foo"])
>>> actual == expected
False
>>> actual - expected
{'car'}
```


When working with sets, subtraction may not always give you what you think, and so methods have been provided for comparisons. In this case, python provides [.difference()](https://docs.python.org/3/library/stdtypes.html#frozenset.difference) and [.symmetric_difference()](https://docs.python.org/3/library/stdtypes.html#frozenset.symmetric_difference):

`symmetric_difference()` would be fitting, as it will emit _any_ item which is not common across both sets. In fact, this is essentially an XOR operation, and python does provide an operator for this - `^`

And so, we could rewrite the comparison with the method:

```
>>> actual.symmetric_difference(expected)
{'car'}
```

or, using the operator:

```
>>> actual ^ expected
{'car'}
```

We'd then need to identify if the element was in `actual` or `expected`, but I'll leave it as an exercise for the reader.
