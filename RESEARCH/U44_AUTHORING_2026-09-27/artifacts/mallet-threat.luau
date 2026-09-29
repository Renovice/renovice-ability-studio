function proto_18(v0, v1, v2)
  local v3, v4, v5, v6
  v3 = v0:Name__8c362f50()
  v3 = v3:Name__cfd1d8a9()
  v5 = Name__9828c6d9.bardMusic
  v4 = Name__6514b208
  v4 = v4(v5)
  if not v4 then
    v6 = Name__9828c6d9.bardMusic
    v5 = v6[v3]
    v4 = Name__6514b208
    v4 = v4(v5)
    if not v4 then
      v6 = Name__9828c6d9.bardMusic
      v5 = v6[v3]
      v5 = v5.box
      v4 = Name__6514b208
      v4 = v4(v5)
      if not v4 then
        v5 = Name__9828c6d9.bardMusic
        v4 = v5[v3]
        v4 = v4.box
        v4:Name__dded29df(v2)
      end
    end
  end
  do return end
end

