# Winitialize

Smarter startupitems for windows.

**Fully alpha, do not use**

## Design

We'll have a set of modules in a folder defined in ps1 files.  We need each to have 

1) prerequisites (optional)
2) a way to start them
3) a way to kill them
4) a way to check whether they are running

Then we can construct the dependency graph, and start and stop processes accordingly.

