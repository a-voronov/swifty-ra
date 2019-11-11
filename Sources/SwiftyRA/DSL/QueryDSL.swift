// All operators are left associative.
// Operator Precedense: high 0 -> low 4

// 0 : relation-name, inline-relation
// 1 : projection, selection, rename (columns), rename (relations), group, order by
// 2 : cross product, theta join, natural join, left outer join, right outer join, full outer join, left semi-join, right semi-join, anti semi-join, division
// 3 : intersection
// 4 : union, subtraction

// Illegal 😢:
//infix operator π
//infix operator σ
//infix operator τ

// Legal:
//infix operator ⍴
//infix operator ←
//infix operator →
//infix operator ∩
//infix operator ∪
//infix operator -
//infix operator ⨯
//infix operator ÷
//infix operator ⨝
//infix operator ⋉
//infix operator ⋊
//infix operator ▷
