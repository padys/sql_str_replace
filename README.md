# *sql* str_replace
fixed php str_replace() as sql function

## Examples:

#### 1.

```sql 
select str_replace('a,b', 'b,c', 'abca');
```

output: `'bccb'`

#### 2. ([PHP DOCS EXAMPLE](http://php.net/manual/pl/function.str-replace.php#example-4545))
```sql 
select str_replace("%body%", "black", "<body text='%body%'>");
```
output: `'<body text=\'black\'>'`

#### 3. ([PHP DOCS EXAMPLE](http://php.net/manual/pl/function.str-replace.php#example-4545))
```sql 
select str_replace(
  CONCAT_WS(",", "fruits", "vegetables", "fiber"), 
  CONCAT_WS(",", "pizza", "beer", "ice cream"), 
  "You should eat fruits, vegetables, and fiber every day."
);
```
or
```sql 
select str_replace(
  "fruits,vegetables,fiber", 
  "pizza,beer,ice cream", 
  "You should eat fruits, vegetables, and fiber every day."
);
```
output: `'You should eat pizza, beer, and ice cream every day.'`

#### 4. ([PHP DOCS EXAMPLE](http://php.net/manual/pl/function.str-replace.php#example-4546))
Such PHP (*example of potential str_replace() gotchas*) code 
```php
<?php
$search  = array('A', 'B', 'C', 'D', 'E');
$replace = array('B', 'C', 'D', 'E', 'F');
$subject = 'A';
echo str_replace($search, $replace, $subject);
```
will end up producing output `'F'`, because as the docs says:
> Outputs F because A is replaced with B, then B is replaced with C, and so on...
> Finally E is replaced with F, because of left to right replacements.

With sql str_replace such weird behaviour will not happen

```sql 
select str_replace(
  CONCAT_WS(',', 'A', 'B', 'C', 'D', 'E'),
  CONCAT_WS(',', 'B', 'C', 'D', 'E', 'F'),
  'A' 
);
```

output: `'B'`

---

# Some benchmarks

To test execution time of functions, one can use [`BENCHMARK(count,expr)`](https://dev.mysql.com/doc/refman/5.5/en/information-functions.html#function_benchmark):

```sql 
select benchmark(100000, str_replace(
  'A,B,C,D,E,G,H,I,J,K,L,M,N,O,P,Q,R,S,T,U,V,W,X,Y,Z',
  '01,02,03,04,05,06,07,08,09,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24,25', 
  'ABCDEGHIJKLMNOPQRSTUVWXYZ'
));
```

Let's test two implementations of `str_replace()` in above benchmark. Here are results (in seconds) for 1, 10, 100, 1000, 10000, 100000 attempts (value of `count` parameter):

* [CaptainRumHandMorgan](https://github.com/CaptainRumHandMorgan/sql_str_replace/commit/3606c3f5d27b9925f6e8c654f1f500a090c7650b): 0.0012, 0.0052, 0.053, 0.47, 4.58, 46.43
* [padys](https://github.com/padys/sql_str_replace/commit/d2e012cabb20c20371bcd470157aeedd02a1ae6a): 0.00064, 0.0064, 0.045, 0.308, 2.967, 30.743

That times aren't average from many tests - only for single run, but... 
My version is almost a little bit faster ;)

Let's try a bit longer "subject" (25k letters) and only 10 attempts:

```sql
select benchmark(10, str_replace(
  'A,B,C,D,E,G,H,I,J,K,L,M,N,O,P,Q,R,S,T,U,V,W,X,Y,Z',
  '01,02,03,04,05,06,07,08,09,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24,25', 
  REPEAT('ABCDEGHIJKLMNOPQRSTUVWXYZ', 1000)
));
```

* [CaptainRumHandMorgan](https://github.com/CaptainRumHandMorgan/sql_str_replace/commit/3606c3f5d27b9925f6e8c654f1f500a090c7650b): 1.468 seconds **(wow!)**
* [padys](https://github.com/padys/sql_str_replace/commit/d2e012cabb20c20371bcd470157aeedd02a1ae6a): 103.001 seconds

But, let's try to get result from each implementation. There should be returned 50k letters.

* [CaptainRumHandMorgan](https://github.com/CaptainRumHandMorgan/sql_str_replace/commit/3606c3f5d27b9925f6e8c654f1f500a090c7650b): only 3709 letters ended with "111213<0.79025314728753140.790253147287" **(there is something WRONG!)**
* [padys](https://github.com/padys/sql_str_replace/commit/d2e012cabb20c20371bcd470157aeedd02a1ae6a): 50k letters **(it's OK!)**

You can see, that astonishing speed is only side effect of incorrect operation of the function ;)

---

# How does it work?
```sql 
select str_replace('a,b', 'b,c', 'abca');
```

step by step:

// TODO
