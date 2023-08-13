
def tointeger num
	case num
	when NumberObject
		num.to_i
	else abort "TODO"	
	end
end
