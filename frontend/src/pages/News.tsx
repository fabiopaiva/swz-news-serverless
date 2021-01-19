import React, {useCallback, useEffect, useState} from "react";
import {Link, RouteComponentProps, withRouter} from "react-router-dom";
import {Alert, Button, Spinner} from "reactstrap";
import ReactMarkdown from 'react-markdown'
import {config} from "../config";
import {News as NewsType} from "../types/news";

export const News = withRouter(({ match: { params: { slug } } }: RouteComponentProps<{ slug: string }>) => {
  const [newsItem, setNewsItem] = useState<NewsType>();
  const [error, setError] = useState<string>();
  const [isLoading, setIsloading] = useState<boolean>(true);

  const loadNewsItem = useCallback(async () => {
    try {
      const response = await fetch(`${config.apiBaseUrl}/news/${slug}`)
      if (!response.ok) {
        setError(`Error fetching data: ${JSON.stringify(await response.json())}`);
      }
      const { data } = await response.json();
      setNewsItem(data);
    } catch (e) {
      setError(e.message);
    } finally {
      setIsloading(false);
    }
  }, [slug]);

  useEffect(() => {
    loadNewsItem();
  }, [loadNewsItem]);

  return <React.Fragment>
    <h3>
      <Button className="float-right" tag={Link} to="/">
        Back
      </Button>
      News - {newsItem?.title}
    </h3>
    <hr />
    {error && <Alert color="danger">Error: {error}</Alert>}
    {isLoading && <Spinner />}
    <div>
      {newsItem && <ReactMarkdown children={newsItem.description} />}
    </div>
  </React.Fragment>
});
