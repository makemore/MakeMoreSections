MakeMoreSections
================

`MakeMoreSections` is a UITableViewDelegate/UITableViewDataSource proxy that allows providing delegates/dataSources per section.
UITableView caches which UITableViewDelegate and UITableViewDataSource methods the dataSource/delegate respondsTo, So `MakeMoreSections` only returns YES
for methods implemented in any of its delegate/datasource collections. If a return method is implemented in one section and not the other/others you can provide default return values or `MakeMoreSections` will for you.
