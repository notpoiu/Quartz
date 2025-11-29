local Levenshtein = {
    Cache = {}
}

function Levenshtein.GetDistance(str1: string, str2: string): number
	if Levenshtein.Cache[str1 .. str2] then
		return Levenshtein.Cache[str1 .. str2]
	end
    
    local len1 = #str1
	local len2 = #str2
	local matrix = {}

	for i = 0, len1 do
		matrix[i] = { [0] = i }
	end
	for j = 0, len2 do
		matrix[0][j] = j
	end

	for i = 1, len1 do
		for j = 1, len2 do
			local cost = (str1:sub(i, i) == str2:sub(j, j)) and 0 or 1
			matrix[i][j] = math.min(matrix[i - 1][j] + 1, matrix[i][j - 1] + 1, matrix[i - 1][j - 1] + cost)
		end
	end

	Levenshtein.Cache[str1 .. str2] = matrix[len1][len2]
	return matrix[len1][len2]
end

function Levenshtein.GetClosestMatch(str: string, table: { [string]: any }, threshold: number?): string | nil
	local minDistance = math.huge
	local closestMatch = ""

	for key, _ in next, table do
		local dist = Levenshtein.GetDistance(str, key)
		if dist < minDistance then
			minDistance = dist
			closestMatch = key
		end
	end

	if threshold and minDistance > threshold then
		return nil
	end

	return closestMatch
end

return Levenshtein
