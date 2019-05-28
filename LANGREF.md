# TCE v1.1 language reference

## Introduction

_Tiered category expressions_ (TCEs) are written in a language specifically designed for matching tiered categories.

A tiered category is defined as a list of tiers where the left most tier is the most generic one (root) and each subsequent tier is a specification (child) of its predecessor (parent). Describing a path through the category tree, up from the root. For instance:

```ruby
["AGF", "Groente", "Komkommer"]
```

TCEs follow the same structure. They consist of category tier names separated by special separators. Here are some examples to get an idea of what TCEs look like:

  - `agf > groente`
  - `agf > groente > komkommer`
  - `agf > groente > komkommer.`
  - `agf > groente > kom%`
  - `agf > groente | fruit > komkommer`
  - `agf > groente > !tomaat`
  - `agf >> komkommer`
  - `>> komkommer`

All of these examples match the category `["AGF", "Groente", "Komkommer"]`. The syntax is explained in more detail in the [next section](#Syntax).

When a TCE is matched with a category:

  - Letter case is ignored, e.g. both "NONFOOD" and "NonFood" match "nonfood" and vice versa.
  - Everything other than alphabetic and numeric characters (including spaces) is ignored, e.g. "nonfood" matches both "non-food" and "non food".
  - Accents are ignored, e.g. "knäckebröd" matches "knackebrod" and vice versa.
  - It matches a _subtree_ of categories, e.g. the TCE `"nonfood"` matches the category `["Nonfood"]` as well as `["Nonfood", "Schoonmaak", "Soda"]`.

Even though they are ignored, tier names in TCEs may contain spaces, upper and lowercase characters and accented characters. To the contrary, they **cannot** contain special characters.

```ruby
# Invalid
"Brood & deegwaren > Volkoren-knäckebröd"

# Valid
"Brood deegwaren > Volkoren knäckebröd"
```

Note that TCEs are considered equal if they match the same categories. E.g. these TCEs are equal:

```ruby
"brood crackers > knäckebröd"
"brood crackers > KNACKEBROD"
"broodcrackers > k n ä c k e b r ö d"
```

## Syntax

### Matching direct children `>`
```ruby
"agf > groente > komkommer"

# Matches
["AGF", "Groente", "Komkommer"]
["AGF", "Groente", "Komkommer", "Snack komkommer"]

# Does not match
["AGF", "Groente"]
["AGF", "Groente", "Tomaat"]
["Groente & fruit", "Groente", "Komkommer"]
```

### Matching descendants at any depth `>>`
```ruby
"agf >> komkommer"

# Matches
["AGF", "Komkommer"]
["AGF", "Komkommer", "Snack komkommer"]
["AGF", "Groente", "Komkommer", "Snack komkommer"]

# Does not match
["AGF"]
["AGF", "Snack komkommer"]
["AGF", "Groente", "Snack komkommer"]
```

### Wildcards `%`
```ruby
"groente% > %komkommer"

# Matches
["Groente", "Komkommer"]
["Groente & fruit", "Snack komkommer"]
```

### Negation `!`
```ruby
"!komkommer"

# Does not match
["Komkommer"]
```

### Lists `|`
```ruby
"veldsla | ijsbergsla | rucola"

# Matches
["Veldsla"]
["IJsbergsla"]
["Rucola"]
```

### Explicit last tier(s) `.`
```ruby
"agf > groente > komkommer."

# Matches
["AGF", "Groente", "Komkommer"]

# Does not match
["AGF", "Groente", "Komkommer", "Snack komkommer"]
```

```ruby
"agf > groente. > komkommer"

# Matches
["AGF", "Groente"]
["AGF", "Groente", "Komkommer"]
["AGF", "Groente", "Komkommer", "Snack komkommer"]

# Does not match
["AGF", "Groente", "Tomaat"]
```

```ruby
"agf > groente. > komkommer."

# Matches
["AGF", "Groente"]
["AGF", "Groente", "Komkommer"]

# Does not match
["AGF", "Groente", "Tomaat"]
["AGF", "Groente", "Komkommer", "Snack komkommer"]
```

### Combining patterns
```ruby
"groente > seizoensgroente > %"

# Matches
["Groente", "Seizoensgroente", "Pastinaak"]
["Groente", "Seizoensgroente", "Vers", "Pastinaak"]

# Does not match
["Groente", "Seizoensgroente"]
```

```ruby
">> !komkommer%"

# Does not match
["Komkommer"]
["Komkommer & fruit"]
["AGF", "Komkommer"]
["AGF", "Komkommer & fruit"]
["AGF", "Groente", "Komkommer"]
```

```ruby
"nonfood >> ! babyvoeding | diervoeding"

# Matches
["Nonfood", "Baby", "Flessen"]
["Nonfood", "Huisdier", "Aanlijnriemen"]

# Does not match
["Nonfood", "Baby", "Babyvoeding"]
["Nonfood", "Huisdier", "Diervoeding"]
["Nonfood", "Babyvoeding"]
["Nonfood", "Diervoeding"]
["Nonfood"]
```

```ruby
"voeding. >> %voeding."

# Matches
["Voeding"]
["Voeding", "Babyvoeding"]
["Voeding", "Diervoeding"]
["Voeding", "Baby", "Babyvoeding"]
["Voeding", "Dier", "Diervoeding"]

# Does not match
["Voeding", "AGF"]
["Voeding", "Babyvoeding", "Newborn"]
["Voeding", "Diervoeding", "Hond"]
["Voeding", "Baby", "Babyvoeding", "Newborn"]
["Voeding", "Dier", "Diervoeding", "Hond"]
```
