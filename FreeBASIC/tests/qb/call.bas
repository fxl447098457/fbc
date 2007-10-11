' TEST_MODE : COMPILE_AND_RUN_OK

call foo0
call foo1(1.1)
call foo2(1.1, 2.2)
call foo3(1.1, 2.2, 3.3)
call foos("AbC")
dim arr(0 to 1) as integer
call fooa(arr())

sub foo0
end sub

sub foo1(v1 as double)
	assert( v1 = 1.1 )
end sub

sub foo2(v1 as double, v2 as double)
	assert( v1 = 1.1 )
	assert( v2 = 2.2 )
end sub

sub foo3(v1 as double, v2 as double, v3 as double)
	assert( v1 = 1.1 )
	assert( v2 = 2.2 )
	assert( v3 = 3.3 )
end sub

sub foos( s as string )
	assert( s = "AbC" )
end sub

sub fooa( arr() as integer )
end sub

call foo0
call foo1(1.1)
call foo2(1.1, 2.2)
call foo3(1.1, 2.2, 3.3)
call foos("AbC")
call fooa(arr())
