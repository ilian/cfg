self: super:

{
  n = self.callPackage ./n {};
  pianoteq = self.callPackage ./pianoteq {};
  cinnxp = self.callPackage ./cinnxp {};
}
