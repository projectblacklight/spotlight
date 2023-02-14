export default class {
  connect() {
    if (window._gaq != null) {
      return _gaq.push(['_trackPageview']);
    } else if (window.pageTracker != null) {
      return pageTracker._trackPageview();
    }
  }
}