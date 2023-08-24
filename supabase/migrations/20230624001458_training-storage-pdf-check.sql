create
or replace function training_available_for_date (training_path text) returns boolean
    security invoker set search_path = public
as $$
select count(id) = 1
from storage.objects
where name = training_path;
$$
language sql stable;