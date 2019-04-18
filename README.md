# AA222Project2_2019

Follow the instructions from the Julia [website](https://julialang.org/downloads/) to install Julia for your platform.

## Setup

```
git clone https://github.com/sisl/AA222Project2_2019.jl
cd A222Project2_2019.jl
julia --project -e "using Pkg; Pkg.resolve()"
```

## Usage

Remember to `cd` into the `AA222Project2_2019.jl` directory.

### For Linux/MAC-OS

#### Python

```
julia --color=yes --project -e 'using AA222Project2_2019; AA222Project2_2019.main("simple", 1, 1000)' project2.py 
julia --color=yes --project -e 'using AA222Project2_2019; AA222Project2_2019.main("simple", 2, 1000)' project2.py 
julia --color=yes --project -e 'using AA222Project2_2019; AA222Project2_2019.main("simple", 3, 1000)' project2.py 
```

#### Julia

```
julia --color=yes --project -e 'using AA222Project2_2019; AA222Project2_2019.main("simple", 1, 1000)' project2.jl 
julia --color=yes --project -e 'using AA222Project2_2019; AA222Project2_2019.main("simple", 2, 1000)' project2.jl 
julia --color=yes --project -e 'using AA222Project2_2019; AA222Project2_2019.main("simple", 3, 1000)' project2.jl 
```

### For Windows

#### Python

```
julia --color=yes --project -e "using AA222Project2_2019; AA222Project2_2019.main("""simple""", 1, 1000)" project2.py 
julia --color=yes --project -e "using AA222Project2_2019; AA222Project2_2019.main("""simple""", 2, 1000)" project2.py 
julia --color=yes --project -e "using AA222Project2_2019; AA222Project2_2019.main("""simple""", 3, 1000)" project2.py 
```

#### Julia

```
julia --color=yes --project -e "using AA222Project2_2019; AA222Project2_2019.main("""simple""", 1, 1000)" project2.jl 
julia --color=yes --project -e "using AA222Project2_2019; AA222Project2_2019.main("""simple""", 2, 1000)" project2.jl 
julia --color=yes --project -e "using AA222Project2_2019; AA222Project2_2019.main("""simple""", 3, 1000)" project2.jl 
```
