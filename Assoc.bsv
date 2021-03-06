
package Assoc;


import List::*;

export Assoc, singleton;
export contains, lookup;
export insertWith, insert;
export mergeWith, merge;
export update, adjust;


//TODO: Find better home for this.
function Maybe#(a) safeHead(List#(a) xs) =
    case (xs) matches
        tagged Nil : return tagged Invalid;
        tagged Cons { _1: .x } : return tagged Valid x;
    endcase;


//An alias for association lists.
typedef List#(Tuple2#(keyT,valueT)) Assoc#(type keyT, type valueT);


//Creates a new association list with a single value "v" at location "k".
function Assoc#(keyT,valueT) singleton(keyT k, valueT v) =
    cons(tuple2(k,v),Nil);


//The function "lookup" is provided by the List package.

//Returns True if the association list "as" has a value at location "k".
function Bool contains(keyT k, Assoc#(keyT,valueT) as)
provisos (Eq#(keyT)) =
    isValid(lookup(k,as));


//Insert value "v" into association list "as" key location "k".
//If there is already a value at this location, combine the two
//with "merge" and store the result.
function Assoc#(keyT,valueT) insertWith(
    function valueT merge(valueT x1, valueT x2),
    keyT k, valueT v, Assoc#(keyT,valueT) as)
provisos (Eq#(keyT)) =
    case (as) matches
        tagged Nil : return singleton(k,v);
        tagged Cons { _1: {.x,.y}, _2: .xs } :
            if (x == k) begin
                return cons(tuple2(k,merge(v,y)),xs);
            end else begin
                return cons(tuple2(x,y),insert(k,v,xs));
            end
    endcase;

//Create a new association list in which each key maps to its value
//in either "as1" or "as2". If the key exists in both lists, combine
//them together with "merge" and store the result at that location.
function Assoc#(keyT,valueT) mergeWith(
    function valueT merge(valueT x1, valueT x2),
    Assoc#(keyT,valueT) as1, Assoc#(keyT,valueT) as2)
provisos (Eq#(keyT)) =
    case (as1) matches
        tagged Nil : return as2;
        tagged Cons { _1: {.x,.y}, _2: .xs } :
            return insertWith(merge,x,y,mergeWith(merge,xs,as2));
    endcase;


function a leftBias(a x, a y) = x;

//Insert value "v" into association list "as" key location "k".
//If there is already a value at this location, it is replaced.
function Assoc#(keyT,valueT) insert(keyT k, valueT v, Assoc#(keyT,valueT) as)
provisos (Eq#(keyT)) =
    insertWith(leftBias,k,v,as);

//Create a new association list in which each key maps to its value
//in either "as1" or "as2". If the key exists in both lists, choose
//the value from "as1".
function Assoc#(keyT,valueT) merge(
    Assoc#(keyT,valueT) as1, Assoc#(keyT,valueT) as2)
provisos (Eq#(keyT)) =
    mergeWith(leftBias,as1,as2);


function Assoc#(keyT,valueT) update(
    function Maybe#(valueT) f(valueT x1),
    keyT k, Assoc#(keyT,valueT) as)
provisos (Eq#(keyT)) =
    case (as) matches
        tagged Nil : return Nil;
        tagged Cons { _1: {.x,.y}, _2: .xs } :
            if (x == k) begin
                return cons(tuple2(k,fromMaybe(y,f(y))),xs);
            end else begin
                return cons(tuple2(x,y),update(f,k,xs));
            end
    endcase;

function Assoc#(keyT,valueT) adjust(
    function valueT f(valueT x1),
    keyT k, Assoc#(keyT,valueT) as)
provisos (Eq#(keyT));
    function maybeF(x) = tagged Valid f(x);
    return update(maybeF,k,as);
endfunction


endpackage