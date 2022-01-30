
# Since this module implements an abstract interface,
# most functionality must be supplied by user
struct NotImplementedError <: Exception end

################################################
# Node Interface
#
# A syntax tree is a hiearchy of nodes. A node
# references a "region" (contiguous sequence of
# characters in the source file) as well as some
# environment data.
################################################
abstract type Node end # trait type, do not inherit

struct Region
    start::Int
    offset::Int
end


typename(node)::Region = throw(NotImplementedError())
region(node)::Region = throw(NotImplementedError())
environment(node)::Any = throw(NotImplementedError())
nodetype(x)::DataType = throw(NotImplementedError())

################################################
# Literal Interface
#
# A literal is a leaf node in the syntax tree.
# It may contain. A literal node must satisfy
# nodetype(node) == Literal()
################################################

struct Literal <: Node end

value(lit)::String = throw(NotImplementedError())
isliteral(node) = nodetype(typeof(node)) == Literal()

################################################
# Parent Interface
#
# A literal is a leaf node in the syntax tree.
# It may contain. A literal node must satisfy
# nodetype(node) == Literal()
################################################

struct Parent <: Node end

# returns vector of nodes
children(parent) = throw(NotImplementedError())
isparent(node) = nodetype(typeof(node)) == Parent()

################################################
# Misc Utilities
################################################

traverse(node; pre=nothing, post=nothing) = begin
    !isnothing(pre) && pre(node)
    isparent(node) && foreach(c->traverse(c; pre=pre, post=post), children(node))
    !isnothing(post) && post(node)
end

display(io, node) = begin
    level = -1
    pre = node -> begin
        level += 1
        print(io, "  "^level)
        isparent(node) && println(io, "$(typename(node))")
        isliteral(node) && println(io, "$(value(node))")
    end
    post = node -> begin
        level -= 1
    end
    traverse(node; pre=pre, post=post)
end


################################################
# Example (HTML)
################################################
abstract type HTMLNode end

struct Element <: HTMLNode
    tag::String
    attrs::Dict{String, String}
    children::Vector{HTMLNode}
    region::Region
end

struct Text <: HTMLNode
    contents::String
    region::Region
end

# Following functions implement SyntaxTree interface
nodetype(::Type{Element}) = Parent()
nodetype(::Type{Text}) = Literal()
region(node::HTMLNode) = node.region
environment(node::HTMLNode) = nothing
children(node::Element) = node.children
value(node::Text) = node.contents
typename(node::Element) = node.tag
typename(node::Text) = "Text"

# example tree
reg = Region(0,0)
el(tag) = x -> begin
    if typeof(x) == String
        Element(tag, Dict{String,String}(), [Text(x, reg)], reg)
    else
        Element(tag, Dict{String,String}(), x, reg)
    end
end

html = el("html")
body = el("body")
h1 = el("h1")
p = el("body")

tree = html([
    body([
        h1("My Webiste"),
        p("Welcome to my Webpage!")
    ])
])

display(stdout, tree)
