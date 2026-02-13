local Test = {}

function Test.Run()
	assert(typeof(hookfunction) == "function", "hookfunction is not a function")
    assert(typeof(newcclosure) == "function", "newcclosure is not a function")
    
    local function CreateNoArgFunc(options)
        local func = function(...)
            assert(select("#", ...) == 0, "Function call should have no arguments.")
            return options.ReturnVal
        end

        if options.NewCC then
            return newcclosure(func)
        end

        return func
    end

    --// Options \\--
    local LuauFuncOptions = { NewCC = false, ReturnVal = true }
    local LuauReturnOptions = { NewCC = false, ReturnVal = false }
    local NewCCFuncOptions = { NewCC = true, ReturnVal = true }
    local NewCCReturnOptions = { NewCC = true, ReturnVal = false }

    --// Luau -> Luau \\--
    local testFunc = CreateNoArgFunc(LuauFuncOptions)
    local ref = hookfunction(testFunc, CreateNoArgFunc(LuauReturnOptions))

    assert(testFunc() == false, "Function should return false")
    assert(ref() == true, "Original function should return true")
    assert(testFunc ~= ref, "Original function should not be same as the reference")

    --// Luau -> C \\--
    local testFunc2 = CreateNoArgFunc(LuauFuncOptions)
    local ref2 = hookfunction(testFunc2, string.match)

    assert(testFunc2("hello67", "hello67"), "Function should return true")
    assert(ref2() == true, "Original function should return true")
    assert(testFunc2 ~= ref2, "Original function should not be same as the reference")

    --// Luau -> NewCC \\--
    local testFunc3 = CreateNoArgFunc(LuauFuncOptions)
    local ref3 = hookfunction(testFunc3, CreateNoArgFunc(NewCCReturnOptions))

    assert(testFunc3() == false, "Function should return false")
    assert(ref3() == true, "Original function should return true")
    assert(testFunc3 ~= ref3, "Original function should not be same as the reference")

    --// NewCC -> Luau \--
    local testFunc4 = CreateNoArgFunc(NewCCFuncOptions)
    local ref4 = hookfunction(testFunc4, CreateNoArgFunc(LuauReturnOptions))

    assert(testFunc4() == false, "Function should return false")
    assert(ref4() == true, "Original function should return true")
    assert(testFunc4 ~= ref4, "Original function should not be same as the reference")

    --// NewCC -> C \--
    local testFunc5 = CreateNoArgFunc(NewCCFuncOptions)
    local ref5 = hookfunction(testFunc5, string.match)

    assert(testFunc5("hello67", "hello67"), "Function should return false")
    assert(ref5() == true, "Original function should return true")
    assert(testFunc5 ~= ref5, "Original function should not be same as the reference")

    --// NewCC -> NewCC \--
    local testFunc6 = CreateNoArgFunc(NewCCFuncOptions)
    local ref6 = hookfunction(testFunc6, CreateNoArgFunc(NewCCReturnOptions))

    assert(testFunc6() == false, "Function should return false")
    assert(ref6() == true, "Original function should return true")
    assert(testFunc6 ~= ref6, "Original function should not be same as the reference")
end

return Test
