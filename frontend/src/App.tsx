import React from 'react';
import {BrowserRouter, Switch, Route, Link} from "react-router-dom";
import {Container, Navbar, NavbarBrand} from "reactstrap";

import { Home } from "./pages/Home";

import 'bootstrap/dist/css/bootstrap.min.css';
import {News} from "./pages/News";

function App() {
  return (
    <BrowserRouter>
      <React.Fragment>
        <Navbar color="dark" dark>
          <Container>
          <NavbarBrand tag={Link} to="/">SWZ News</NavbarBrand>
          </Container>
        </Navbar>
        <Container className="mt-5">
          <Switch>
            <Route path="/news/:slug">
              <News />
            </Route>
            <Route path="/">
              <Home />
            </Route>
          </Switch>
        </Container>
      </React.Fragment>
    </BrowserRouter>
  );
}

export default App;
