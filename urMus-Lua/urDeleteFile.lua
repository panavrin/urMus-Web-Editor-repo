
dofile(SystemPath("urSelectorDialog.lua"))


local deletefile

function ConfirmDelete()
	os.remove(deletefile)
end

function DeleteFile(file,path)
	deletefile = path..file
	SelectorDialog("Delete "..file.."?",2,"OK",ConfirmDelete,"Cancel",nil)
end

local scrollentries = {}

--[[for v in lfs.dir(SystemPath("")) do
	if v ~= "." and v ~= ".." then
		local entry = { v, nil, SystemPath(""), DeleteFile, {200,84,84,255}, SystemPath("")}
		table.insert(scrollentries, entry)			
	end
end--]]
for v in lfs.dir(DocumentPath("")) do
	if v ~= "." and v ~= ".." then
		local entry = { v, "DocumentPath", nil, DeleteFile, {84,84,84,255}, DocumentPath("")}
		table.insert(scrollentries, entry)			
	end
end

urScrollList:OpenScrollListPage(scrollpage, "Delete File", nil, nil, scrollentries)
