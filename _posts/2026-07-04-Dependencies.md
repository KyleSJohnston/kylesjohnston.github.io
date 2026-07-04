---
title: Code Dependencies & Security
date: 2026-07-04 12:00:00 -0400
categories: [Programming, Security]
tags: [dependencies]     # TAG names should always be lowercase
toc: true   # default
pin: false  # default
image:
  path: /assets/img/pexels-shottrotter-791778.jpg
  alt: '"A captivating view of a modern spiral staircase structure in Lommel, Belgium." <a href="https://www.pexels.com/photo/low-angle-photography-of-tower-791778/">Source</a>'
---

Even for basic data analysis, programming with dependences requires judgments about security.

Essentially all modern code depends on some preexisting code. High level programming languages offer a wide range of functionality meant to simplify the developer experience. Algorithms and data structures form reusable components that abstract away the implementation details. In all probability, anything one might want to do with a computer can be decomposed into a collection of well-known concepts combined creatively.

The general term for this preexisting code is a dependency. They can take many forms: from supplemental source code to fully-compiled binaries. Dependencies have clear benefits, and programmers tend to gravitate toward ecosystems of quality dependencies. Quality is often defined by functionality, but there's a strong case for considering security. Even if you only code to analyze data, you need to have an awareness of the security implications of your dependencies.

> I like to code in [Julia](https://julialang.org/). It's a great language for working with data because it's expressive and performant. Throughout this post, I'm going to offer examples specific to Julia to highlight key concepts. Many of these concepts apply to other programming languages and to software environments generally. My hope is that these examples remain intuitive even without any previous experience in Julia.
{: .prompt-info }

## Encapsulating Reusable Work

For anyone new to programming, it might be helpful to see a toy example of a dependency.

### Shapes

```julia
module Shapes


export area, Circle, Rectangle, Triangle

struct Rectangle
  base
  height
end

area(x::Rectangle) = x.base * x.height

struct Triangle
  base
  height
end

area(x::Triangle) = 0.5 * x.base * x.height

struct Circle
  radius
end

area(x::Circle) = π * x.radius^2

end  # module
```
Define an object to represent a rectangle and a function to compute it's area


The code defines three shapes&mdash;`Rectangle`, `Triangle`, and `Circle`&mdash;and an `area` function. All of this is contained within a `Shapes` module, which groups everything together. Anyone with access to the module can use it.

```julia
using Shapes

my_shapes = [
  Rectangle(3, 5),
  Triangle(2, 1),
  Circle(1),
]

total_area = 0.0
for s in my_shapes
  total_area += area(s)
end
```

It doesn't take much to use Shapes as a dependency: you need to know which shapes it provides, how to create them, and that you can call area on the resulting object. _Crucially, you don't need read the entire module or even know the formulas for `area`._ This last point is incredibly convenient, especially when the dependency is more complex.

### Plots

Plotting is a great example of a complex dependency. The work necessary to generate a plot is almost entirely distinct from the work needed to generate the values. It involves the drawing of points/lines/axes/titles with customization options for colors/shading/labels and rendering in different contexts and formats. All this work is largely agnostic to the data values in question. Much of the logic can be reused across different types of plots (e.g., line plots, scatter plots, etc.), so it's reasonable to bundle the various plotting components together. This bundling also offers the opportunity to keep naming and options consistent, providing the user a [coherent interface to plotting functionality](https://aog.makie.org/stable/#Example).

By contrast, the work that uses plots is entirely disparate and diverse. The data values might be extracted from a file or a database&mdash;or they might be the end result of a long series of expert calculations. The user knows the meaning of the data in a way that the plotting library cannot; this knowledge informs the customization of the plot to make insights accessible to the audience. _This work elevates a plot from a graphic to a presentation._ 

The correct paradigm for plotting is a dependency relationship between user code and plotting code. It would be a tremendous waste of time if every possible user had to grapple with the challenges of plotting work. Instead, one person or one team identifies the critical sub-problems within plotting, considers implementation trade-offs, and puts serious effort into designing code for others to use.

## Package Ecosystems

Many, many programming tasks have similar properties that warrant a dependency relationship. File formats. Internet requests. Array math. Random number generation. Statistical distributions. Regressions. Using the right dependency for these problems allows you to do expert things without becoming one. Even if you _are_ an expert in one of these areas, you would be better off using the existing code&mdash;and suggesting updates should you find a shortcoming.

Most programmers looking to do anything useful expect to rely on at least one dependency. To anticipate this, programming languages offer standard library dependencies that ship with the language itself and package managers that make it trivially easy to add new dependencies.

The Julia language offers a substantial standard library on top of `Base` code. `Base` offers types and collections and essential functionality; everything in `Base` is available by default. The standard library provides statistics, date and time functionality, logging, and ways to read and write .toml files (and much more). These reflect common usage that can be added selectively to new code (i.e., `] add Logging` to bring the package into the environment and `using Logging` in the code).

The standard library only forms part of the dependency picture in Julia. There are many, many packages providing a wide array of code. [IJulia.jl](https://www.juliapackages.com/p/ijulia) and [Pluto.jl](https://www.juliapackages.com/p/pluto) offer notebook-style interfaces for data analysis. [Makie.jl](https://www.juliapackages.com/p/makie) is a popular plotting library. [DuckDB.jl](https://www.juliapackages.com/p/duckdb) offers a Julia interface to DuckDB, an in-process SQL database.

From a user's perspective, packages in the [General](https://github.com/JuliaRegistries/General) registry are just as available as packages in the standard library. For example, accessing [DataFrames.jl](https://dataframes.juliadata.org/stable/) to work with tabular data is simply `] add DataFrames` and `using DataFrames`. The inclusion process is exactly the same, and the distinction can start to feel arbitrary. I've used [JSON.jl](https://juliaio.github.io/JSON.jl/stable/) more than [TOML](https://docs.julialang.org/en/v1/stdlib/TOML/); [ZipArchives.jl](https://docs.juliahub.com/General/ZipArchives/stable/) more than [TAR](https://docs.julialang.org/en/v1/stdlib/Tar/).

> Different programming languages make different judgments about what belongs in the standard library. I mentioned DataFrames.jl above, but I was first introduced to the concept of DataFrames in [R](https://search.r-project.org/R/refmans/base/html/data.frame.html) where it's a core part of the language. In Python, DataFrames are provided by [pandas](https://pandas.pydata.org/docs/user_guide/dsintro.html#dataframe) and [Polars](https://docs.pola.rs/user-guide/concepts/data-types-and-structures/#dataframe).
{: .prompt-info }

Dependency code can run as soon as it's introduced into your environment. In Julia, this is the [build](https://pkgdocs.julialang.org/v1/creating-packages/#Adding-a-build-step-to-the-package) [step](https://pkgdocs.julialang.org/v1/managing-packages/#Building-packages), which can be useful for customizing the code for your operating system or hardware. (More generally, any "expensive" work that only needs to be done once.) There is another opportunity for dependency code to run at the [initialization step](https://docs.julialang.org/en/v1/manual/modules/#Module-initialization-and-precompilation) when you first include it in your code&mdash;possibly to perform some configuration or set up some global variables. The overall effect is to make using the dependency as seamless as possible.

## Implicit Trust
Dependency code runs alongside your code with the same privileges and permissions. There's an implicit trust in allowing code to run without inspecting it and understanding it&mdash;which may not always be possible. Some dependencies are compiled or are written in a different programming language. It's one thing to verify that a dependency produces an expected result; it's another to verify that the dependency is doing _only_ that and nothing else.

### Scope of Attack Surface

For the sake of argument, let's pretend that the dependency is fully transparent: the source code is available and readable. (Julia programmers are fortunate that many dependencies are also written in Julia due to the design of the language.) For any sufficiently complex work, this is likely to be a lot of code, which may be challenging to read and reason about. Learning how the dependency implements its behavior is rarely worth the effort.

As an example, [PromptingTools.jl](https://github.com/svilupp/PromptingTools.jl#using-anthropic-models) requires API keys to be set for any LLM providers. Anthropic's Claude requies `ANTHROPIC_API_KEY`; Google's Gemini requires `GOOGLE_API_KEY`; OpenAI's GPT requires `OPENAI_API_KEY`; and so on. PromptingTools.jl can read them from `ENV`, but so can any other code. _There is no segmentation with this setup._ Nothing prevents a devious dependency from checking `ENV` for all the well-known secrets and doing something[^something] with them.

[^something]: I'm not going to suggest anything specific here. Use your imagination, or possibly extrapolate from the known supply-chain attacks.

The lack of segmentation creates an attack surface, a collection of opportunities for a malicious actor to potentially access your environment. Simply adding DataFrames.jl to a clean environment requires 22 [direct](https://github.com/JuliaData/DataFrames.jl/blob/3924697ea6c02ac186a95b298a4e06b52e881b53/Project.toml#L5-L27) dependencies and another 15 indirect dependencies. Makie.jl has 59 [direct](https://github.com/MakieOrg/Makie.jl/blob/c92d45f0e1a2a34a3795add3a15c925d648391fc/Makie/Project.toml#L6-L65) dependencies and 222 indirect dependencies. Any one of them could be a security point of failure, and it represents an overwhelming amount of code to audit.

### Coding Agents
Vibe coding changes all of the dynamics here. LLM agents are constantly creating new environments and importing dependencies freely&mdash;far faster than a human could evaluate them. More specifically, relative to a traditional coding workflow, LLMs will end up incorporating more new dependencies and more updates to existing dependencies. The pace is so rapid that trust can only be achieved by policy.

An update policy is especially problematic. On the one hand, it would be sensible to slow down the rate of updates to allow for human review. In an extreme version of this, every version of every dependency could be pre-approved. On the other hand, this delays any security-related updates when the same LLM agents make it trivially easy to infer the vulnerability from the update.

Because so much of my experience is anchored to pre-LLM expectations, I mostly try to keep coding agents away from modifying my environment. I rely on a combination of rules and supervision. I won't claim that it's more secure, but it makes me feel a little better about using these tools. I take a similar approach to any of the chatbot interfaces: I'm not very trusting with plugins and MCP servers, I'm very deliberate about the scope of information I upload, and I assume the frontier labs are better equipped to manage software containers.

## Preventative Measures

Since it is largely impractical for most programmers to fully evaluate every dependency, the best a programmer can do is fall back on a heuristic for trust. I find the range of options to be disappointing, and even a combination of them cannot guarantee perfect security. In the wake of several recent supply chain attacks to [npm](https://about.gitlab.com/blog/gitlab-discovers-widespread-npm-supply-chain-attack/) and [AUR](https://risky.biz/risky-bulletin-arch-linux-supply-chain-attack-spreads-to-1-900-aur-packages/), I hope better solutions become available.

> Although it's several years old now, CISA's [Defending Against Software Supply Chain Attacks](https://www.cisa.gov/sites/default/files/publications/defending_against_software_supply_chain_attacks_508.pdf) offers a more extensive discussion of the risks and mitigation strategies. It's an accessible document with relevant historical context.
{: .prompt-info }

I know the open-source community is aware of this problem, and I'm sure there are people working on making package ecosystems safer. But absent major innovations, users still need some guidelines for protecting themselves from malicious dependencies.

### Activity & Popularity

Actively maintained code should be more likely to update in response to a known vulnerability. It can be helpful to know the code was updated recently and how many people contribute their effort to the project. More maintainers means more code review and better security.

Code-hosting sites show "stars" as a community rating for the code. Albeit imperfect, this proxies how many people find the dependency to be useful and worth the security exposure.

### Location

The source location of the dependency can imply some assurance about quality. (App repositories for mobile devices are supposed to make downloads safer by reviewing apps for standards.) In Julia, the [General](https://github.com/JuliaRegistries/General) package registry serves as the default location for dependencies that meet a set of [guidelines](https://juliaregistries.github.io/RegistryCI.jl/stable/guidelines/#Automatic-merging-guidelines). Meeting the standards is fairly straightforward and has little bearing on code security.

I wouldn't be surprised if we saw some package ecosystems adopt higher-trust policies on an opt-in basis. From my perspective, it seems like an easy way to communicate security when needed.

### Version or Content Hash

Dependencies are typically denoted by major-minor-patch version numbers (i.e., "1.12.5"). [Rules](https://semver.org/) about changing version numbers vary, but incrementing a patch number typically indicates a small change whereas incrementing a major number indicates a large change. Julia's Pkg.jl offers a way to [restrict versions](https://pkgdocs.julialang.org/v1/compatibility/) of dependencies to compatible ranges in the [Project.toml](https://pkgdocs.julialang.org/v1/toml-files/#The-[compat]-section) that defines the environment.

The security community [recommends pinning dependencies](https://docs.github.com/en/code-security/concepts/supply-chain-security/best-practices-for-maintaining-dependencies) based on content hash and monitoring for known malicious versions. Pinning by content hash means that the dependency cannot change without changing the hash value. In Julia, this is recorded in the [Manifest.toml](https://pkgdocs.julialang.org/v1/toml-files/#Manifest.toml) that lists every dependency's `git-tree-sha1` value. My understanding is that this originated out of a need for reproducible research, but the added benefit is security log of dependencies.

### Gatekeeping & Avoidance

Security-critical conditions may require allow-listing dependencies based on a review process. This adds significant friction and requires dedicated resources. Doing this in Julia would require [removing](https://pkgdocs.julialang.org/v1/repl/#registry-commands) the General registry and supplying a [custom registry](https://github.com/GunnarFarneback/LocalRegistry.jl) with only the approved packages.

In this scenario, new code will need to be written to overcome gaps in functionality&mdash;and that, too, has a cost.

## Final Considerations

Security postures vary widely. What might be appropriate in one situation or application might be incredibly risky for another. There are no universal recommendations, and there is no substitute for trust. The same trust that makes a dependency ecosystem effective also makes it a target.

Computer security is little more than a background thought for many programming roles. When the primary objectives are sourcing and making sense of data, it's easy to lose track of the attack surface formed by the code and dependencies. That's worth remembering, even if functionality seems more important.
