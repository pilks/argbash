dnl We wrap the generated stuff into m4_ignore, so when we re-run the script, the results will be +- the same. Devillish!
m4_define([_ARGBASH_GO], [m4_do(
	[ARGBASH_GO_BASE([$1])],
)])
m4_divert_push([STDOUT])dnl
