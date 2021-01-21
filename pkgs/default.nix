self: super:

{
  pianoteq = self.callPackage ./pianoteq {};
  reaper = self.callPackage ./reaper {};
}
